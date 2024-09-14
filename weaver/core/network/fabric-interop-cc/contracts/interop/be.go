/*
Copyright IBM Corp. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"errors"
	"fmt"

	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/json"
	"io"

	math "github.com/IBM/mathlib"
)

type PublicParameters struct {
	// Generator of G1
	P *math.G1
	// Powers P^{td}, P^{td^2},..., P^{td^N}
	FirstHalf []*math.G1
	// Powers P^{td^{N+2}}, P^{td^{N+3}},..., P^{td^{2N}}
	SecondHalf []*math.G1
	// Generator of G2
	H *math.G2
	// Powers H^{td}, H^{td^2},..., H^{td^N}
	FirstHalfInG2 []*math.G2
	// Identifier of the bilinear group
	CurveID int
	// Number of participants in the broadcast encryption
	N int
}

type DecryptionKeys []DecryptionKey

type PublicKey *math.G1

type DecryptionKey *math.G1

type Ciphertext struct {
	C0         *math.G2
	C1         *math.G1
	Encryption []byte
}

func GetPublicKeyAndParamsFromDistPublicParams(dpp *DistPublicParameters) (PublicKey, *PublicParameters, error) {
	if dpp == nil || len(dpp.P) == 0 || len(dpp.H) == 0 || len(dpp.T) == 0 || dpp.N <= 0 || dpp.P[0] == nil || dpp.H[0] == nil || dpp.T[0] == nil || len(dpp.P) != 2 * dpp.N || len(dpp.H) != dpp.N + 1 || len(dpp.T) != dpp.N + 1 {
		return nil, nil, errors.New(fmt.Sprintf("One or more attributes in DPP is missing or invalid"))
	}

	publicParams := &PublicParameters{}
	publicParams.P = dpp.P[0]
	publicParams.H = dpp.H[0]
	publicParams.CurveID = dpp.CurveID
	publicParams.N = dpp.N
	for i := 0; i < dpp.N; i++ {
		publicParams.FirstHalf[i] = dpp.P[i + 1]
		publicParams.FirstHalfInG2[i] = dpp.H[i + 1]
	}
	for i := 0; i < dpp.N - 1; i++ {
		publicParams.SecondHalf[i] = dpp.P[i + dpp.N + 1]
	}

	publicKey := dpp.T[0]

	return publicKey, publicParams, nil
}

func (pp *PublicParameters) Gen(cid, N int, seed []byte) error {
	pp.N = N
	pp.CurveID = cid

	curve := math.Curves[cid]
	rand, err := curve.Rand()
	if err != nil {
		return err
	}

	pp.P = curve.HashToG1(seed)
	pp.H = curve.GenG2.Mul(curve.NewRandomZr(rand))

	pp.FirstHalf = make([]*math.G1, N)
	pp.SecondHalf = make([]*math.G1, N-1)

	// trapdoor for public parameters
	td := curve.NewRandomZr(rand)
	tau := td.PowMod(curve.NewZrFromInt(int64(N + 2)))
	pp.FirstHalf[0] = pp.P.Mul(td)
	pp.SecondHalf[0] = pp.P.Mul(tau)
	for i := 1; i < N-1; i++ {
		pp.FirstHalf[i] = pp.FirstHalf[i-1].Mul(td)
		pp.SecondHalf[i] = pp.SecondHalf[i-1].Mul(td)
	}
	pp.FirstHalf[N-1] = pp.FirstHalf[N-2].Mul(td)

	pp.FirstHalfInG2 = make([]*math.G2, N)
	pp.FirstHalfInG2[0] = pp.H.Mul(td)
	for i := 1; i < N; i++ {
		pp.FirstHalfInG2[i] = pp.FirstHalfInG2[i-1].Mul(td)
	}
	return nil
}

func KeyGen(pp *PublicParameters) (DecryptionKeys, PublicKey, error) {
	dk := make([]DecryptionKey, pp.N)
	curve := math.Curves[pp.CurveID]
	rand, err := curve.Rand()
	if err != nil {
		return nil, nil, err
	}
	// trapdoor for public parameters
	sk := curve.NewRandomZr(rand)
	// public key of the broadcast encryption
	pk := pp.P.Mul(sk)
	for i := 0; i < pp.N; i++ {
		// decryption key for participant i
		dk[i] = pp.FirstHalf[i].Mul(sk)
	}
	return dk, pk, nil
}

func DistKeyGen(dpp *DistPublicParameters, index int, secret *math.Zr) DecryptionKey {
	DK := dpp.T[index]
	// Multiple with 'secret' 'index' times
	for i := 0 ; i < index ; i++ {
		DK = DK.Mul(secret)
	}

	return DK
}

func Encrypt(plaintext []byte, target []int, pk PublicKey, pp *PublicParameters) ([]byte, error) {
	curve := math.Curves[pp.CurveID]
	random, err := curve.Rand()
	if err != nil {
		return nil, err
	}
	r := curve.NewRandomZr(random)
	C0 := pp.H.Mul(r)
	C1 := curve.NewG1()
	for i := 0; i < len(target); i++ {
		C1.Add(pp.FirstHalf[pp.N-target[i]])
	}
	C1.Add(pk)
	C1 = C1.Mul(r)

	K := curve.Pairing(pp.FirstHalfInG2[0], pp.FirstHalf[pp.N-1].Mul(r))
	K = curve.FExp(K)

	enc, err := symEncrypt(plaintext, K)
	if err != nil {
		return nil, err
	}

	return json.Marshal(&Ciphertext{C0: C0, C1: C1, Encryption: enc})
}

func Decrypt(raw []byte, dk DecryptionKey, target []int, index int, pp *PublicParameters) ([]byte, error) {
	ciphertext := &Ciphertext{}
	err := json.Unmarshal(raw, ciphertext)
	if err != nil {
		return nil, err
	}
	curve := math.Curves[pp.CurveID]
	S := curve.Pairing(pp.FirstHalfInG2[index-1], ciphertext.C1)
	U := curve.NewG1()
	for i := 0; i < len(target); i++ {
		if target[i] == index {
			continue
		}
		j := pp.N - target[i] + index
		if j < pp.N {
			U.Add(pp.FirstHalf[j])
		} else {
			U.Add(pp.SecondHalf[index-target[i]-1])
		}
	}
	U.Add(dk)
	T := curve.Pairing(ciphertext.C0, U)
	T.Inverse()
	S.Mul(T)
	S = curve.FExp(S)

	return symDecrypt(ciphertext.Encryption, S)

}

func symEncrypt(plaintext []byte, K *math.Gt) ([]byte, error) {
	h := sha256.New()
	h.Write(K.Bytes())

	aesCipher, err := aes.NewCipher(h.Sum(nil))
	if err != nil {
		return nil, err
	}

	// gcm or Galois/Counter Mode, is a mode of operation
	// for symmetric key cryptographic block ciphers
	// - https://en.wikipedia.org/wiki/Galois/Counter_Mode
	gcm, err := cipher.NewGCM(aesCipher)
	if err != nil {
		return nil, err
	}

	// creates a nonce
	// which must be passed to Seal
	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, err
	}
	return gcm.Seal(nonce, nonce, plaintext, nil), nil
}

func symDecrypt(ciphertext []byte, K *math.Gt) ([]byte, error) {
	h := sha256.New()
	h.Write(K.Bytes())

	aesCipher, err := aes.NewCipher(h.Sum(nil))
	if err != nil {
		return nil, err
	}
	// gcm or Galois/Counter Mode, is a mode of operation
	// for symmetric key cryptographic block ciphers
	// - https://en.wikipedia.org/wiki/Galois/Counter_Mode
	gcm, err := cipher.NewGCM(aesCipher)
	if err != nil {
		return nil, err
	}
	//Get the nonce size
	nonceSize := gcm.NonceSize()

	//Extract the nonce from the encrypted data
	nonce, enc := ciphertext[:nonceSize], ciphertext[nonceSize:]

	//Decrypt the data
	plaintext, err := gcm.Open(nil, nonce, enc, nil)
	if err != nil {
		return nil, err
	}
	return plaintext, nil
}
