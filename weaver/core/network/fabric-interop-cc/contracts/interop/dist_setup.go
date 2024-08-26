/*
Copyright IBM Corp. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"fmt"

	math "github.com/IBM/mathlib"
	"github.com/pkg/errors"
)

// DistPublicParameters are modified Boneh-Boyen broadcast public parameters
type DistPublicParameters struct {
	// P is an array of powers P^{td^0}, P^{td}, ..., P^{td^N}, P^{td^{N+2}}, ..., P^{td}
	P []*math.G1
	// H is an array of powers H^{td^0}, P^{td}, ..., H^{td^N}
	H []*math.G2
	// T is an array of powers T^{td^0}, T^{td}, ..., T^{td^N}
	T []*math.G1
	// N is the size of the broadcast group
	N int
	// CurveID is the identifier of the curve
	CurveID int
}

// ZKProof shows that there exists x \in Zp such that  X = P^x
type ZKProof struct {
	Challenge *math.Zr
	Proof     *math.Zr
}

// InitRequest is submitted by a participant to initialize the distributed public parameters.
type InitRequest struct {
	Seed                     []byte
	RandomZr                 *math.Zr
	InitDistPublicParameters *DistPublicParameters
}

// UpdateRequest is submitted by a participant to update the distributed public parameters.
type UpdateRequest struct {
	Index                   int
	Proof                   *ZKProof
	NewDistPublicParameters *DistPublicParameters
}

func NewUpdateRequest(dpp *DistPublicParameters, proof *ZKProof, index int) *UpdateRequest {
	return &UpdateRequest{
		Proof:                   proof,
		NewDistPublicParameters: dpp,
		Index:                   index,
	}
}

func NewDistPublicParameters(cid, N int) *DistPublicParameters {
	dpp := &DistPublicParameters{}
	dpp.P = make([]*math.G1, 2*N)
	dpp.H = make([]*math.G2, N+1)
	dpp.T = make([]*math.G1, N+1)
	dpp.N = N
	dpp.CurveID = cid
	return dpp
}

// Init initializes DistPublicParameters
// P is an array made of P, P, ..., P
// H is an array made of H, H, ... H
// T is an array made of T, T, ..., T
func (dpp *DistPublicParameters) Init(cid, N int, seed []byte) (*InitRequest, error) {
	dpp.CurveID = cid
	dpp.N = N
	dpp.P = make([]*math.G1, 2*N)
	dpp.H = make([]*math.G2, N+1)
	dpp.T = make([]*math.G1, N+1)

	curve := math.Curves[cid]
	dpp.P[0] = curve.HashToG1(seed)
	for i := 1; i < len(dpp.P); i++ {
		dpp.P[i] = dpp.P[0].Copy()
	}
	rand, err := curve.Rand()
	if err != nil {
		return nil, err
	}

	randomZr := curve.NewRandomZr(rand)
	dpp.H[0] = curve.GenG2.Mul(randomZr)
	for i := 1; i < len(dpp.H); i++ {
		dpp.H[i] = dpp.H[0].Copy()
	}

	dpp.T[0] = curve.HashToG1(append(seed, []byte("1")...))
	for i := 1; i < len(dpp.T); i++ {
		dpp.T[i] = dpp.T[0].Copy()
	}

	return &InitRequest{
		Seed:                     seed,
		RandomZr:                 randomZr,
		InitDistPublicParameters: dpp,
	}, nil
}

// Update allows participant whose positioned at index  to update the receiver using the trapdoor x
func (dpp *DistPublicParameters) Update(index int, x *math.Zr) (*UpdateRequest, error) {
	newDPP := NewDistPublicParameters(dpp.CurveID, dpp.N)
	curve := math.Curves[dpp.CurveID]
	newDPP.P[0] = dpp.P[0].Copy()
	newDPP.H[0] = dpp.H[0].Copy()
	newDPP.T[0] = dpp.T[0].Copy()
	y := x.Copy()
	for i := 1; i < dpp.N+1; i++ {
		// compute P_i^{x^i}
		newDPP.P[i] = dpp.P[i].Mul(y)
		// compute H_i^{x^i}
		newDPP.H[i] = dpp.H[i].Mul(y)

		if i != index {
			// compute T_i^{x^i}
			newDPP.T[i] = dpp.T[i].Mul(y)
		} else {
			newDPP.T[i] = dpp.T[i].Copy()
		}
		y = curve.ModMul(x, y, curve.GroupOrder)
	}

	y = curve.ModMul(x, y, curve.GroupOrder)
	for i := dpp.N + 1; i < len(dpp.P); i++ {
		// compute P_i^{x^i}
		newDPP.P[i] = dpp.P[i].Mul(y)
		y = curve.ModMul(x, y, curve.GroupOrder)
	}
	// prove that dpp.P[1]^x = newDPP.P[1]
	proof, err := computeZKProof(dpp.P[1], newDPP.P[1], x, curve)
	if err != nil {
		return nil, err
	}

	return &UpdateRequest{
		Index:                   index,
		Proof:                   proof,
		NewDistPublicParameters: newDPP,
	}, nil
}

// VerifyInit verifies whether the initRequest is valid
func VerifyInit(initRequest *InitRequest) (*DistPublicParameters, error) {
	// verify well-formedness
	if initRequest.Seed == nil || len(initRequest.Seed) == 0 || initRequest.RandomZr == nil || initRequest.InitDistPublicParameters == nil || initRequest.InitDistPublicParameters.P[0] == nil || initRequest.InitDistPublicParameters.H[0] == nil || initRequest.InitDistPublicParameters.T[0] == nil {
		return nil, errors.New("bad init request")
	}

	dpp := initRequest.InitDistPublicParameters
	curve := math.Curves[dpp.CurveID]
	dppPVal := curve.HashToG1(initRequest.Seed)
	for i := 0; i < len(dpp.P); i++ {
		if !dpp.P[i].Equals(dppPVal) {
			return nil, errors.New(fmt.Sprintf("Param P-value at index %d (%+v) does not match seed hash", i, dpp.P[i]))
		}
	}

	dppHVal := curve.GenG2.Mul(initRequest.RandomZr)
	for i := 0; i < len(dpp.H); i++ {
		if !dpp.H[i].Equals(dppHVal) {
			return nil, errors.New(fmt.Sprintf("Param H-value at index %d (%+v) does not match point on curve", i, dpp.H[i]))
		}
	}

	dppTVal := curve.HashToG1(append(initRequest.Seed, []byte("1")...))
	for i := 0; i < len(dpp.T); i++ {
		if !dpp.T[i].Equals(dppTVal) {
			return nil, errors.New(fmt.Sprintf("Param T-value at index %d (%+v) does not match appended seed hash", i, dpp.T[i]))
		}
	}

	return dpp, nil
}

// VerifyUpdate verifies whether the updateRequest is valid with respect to the old
// distributed public parameters
func VerifyUpdate(old *DistPublicParameters, updateRequest *UpdateRequest) (*DistPublicParameters, error) {
	curve := math.Curves[old.CurveID]	// TODO: Verify that this works instead of passing 'curve' as argument to the function
	// verify well-formedness
	if updateRequest.NewDistPublicParameters == nil || updateRequest.NewDistPublicParameters.P[0] == nil || updateRequest.NewDistPublicParameters.H[0] == nil || updateRequest.NewDistPublicParameters.T[0] == nil || updateRequest.Index == 0 {
		return nil, errors.New("bad update request")
	}
	if !old.P[0].Equals(updateRequest.NewDistPublicParameters.P[0]) || !old.H[0].Equals(updateRequest.NewDistPublicParameters.H[0]) || !old.T[0].Equals(updateRequest.NewDistPublicParameters.T[0]) || old.N != updateRequest.NewDistPublicParameters.N || old.CurveID != old.CurveID {
		return nil, errors.New("invalid update request")
	}
	P1 := updateRequest.NewDistPublicParameters.P[1]
	// verify that old.P[1]^x = P1
	err := verifyZKProof(old.P[1], P1, updateRequest.Proof, curve)
	if err != nil {
		return nil, err
	}
	P0 := updateRequest.NewDistPublicParameters.P[0]
	H0 := updateRequest.NewDistPublicParameters.H[0]
	H1 := updateRequest.NewDistPublicParameters.H[1]
	H2 := updateRequest.NewDistPublicParameters.H[2]

	// verify that e(P1, H0) = e(P0, H1)
	R := curve.NewG2()
	R.Sub(H0)
	if !curve.FExp(curve.Pairing2(R, P1, H1, P0)).IsUnity() {
		return nil, errors.New("invalid update request")
	}
	for i := 1; i < old.N; i++ {
		// verify that e(updateRequest.NewDistPublicParameters.P[i+1], H0) = e(updateRequest.NewDistPublicParameters.P[i], H1)
		S := curve.NewG1()
		S.Sub(updateRequest.NewDistPublicParameters.P[i+1])
		if !curve.FExp(curve.Pairing2(H1, updateRequest.NewDistPublicParameters.P[i], H0, S)).IsUnity() {
			return nil, errors.New("invalid update request")
		}
		// verify that e(P0, updateRequest.NewDistPublicParameters.H[i+1]) = e(P1, updateRequest.NewDistPublicParameters.H[i])
		U := curve.NewG2()
		U.Sub(updateRequest.NewDistPublicParameters.H[i+1])
		V := curve.Pairing2(updateRequest.NewDistPublicParameters.H[i], P1, U, P0)
		if !curve.FExp(V).IsUnity() {
			return nil, errors.New("invalid update request")
		}
	}

	for i := old.N + 1; i < len(updateRequest.NewDistPublicParameters.P)-1; i++ {
		// verify that e(updateRequest.NewDistPublicParameters.P[i+1], H0) = e(updateRequest.NewDistPublicParameters.P[i], H1)
		S := curve.NewG1()
		S.Sub(updateRequest.NewDistPublicParameters.P[i+1])
		if !curve.FExp(curve.Pairing2(H1, updateRequest.NewDistPublicParameters.P[i], H0, S)).IsUnity() {
			return nil, errors.Errorf("invalid update request %d", i)
		}
	}
	// verify that e(updateRequest.NewDistPublicParameters.P[N+1], H0) = e(updateRequest.NewDistPublicParameters.P[N], H2)
	if !curve.FExp(curve.Pairing2(R, updateRequest.NewDistPublicParameters.P[old.N+1], H2, updateRequest.NewDistPublicParameters.P[old.N])).IsUnity() {
		return nil, errors.New("invalid update request ")
	}
	for i := 1; i < old.N+1; i++ {
		if i == updateRequest.Index {
			if !updateRequest.NewDistPublicParameters.T[i].Equals(old.T[i]) {
				return nil, errors.New("invalid update request ")
			}
		} else {
			// verify that e(updateRequest.NewDistPublicParameters.T[i], old.H[i]) = e(old.T[i], updateRequest.NewDistPublicParameters.H[i])
			S := curve.NewG2()
			S.Sub(old.H[i])
			if !curve.FExp(curve.Pairing2(S, updateRequest.NewDistPublicParameters.T[i], updateRequest.NewDistPublicParameters.H[i], old.T[i])).IsUnity() {
				return nil, errors.New("invalid update request")
			}
		}
	}
	return updateRequest.NewDistPublicParameters, nil
}

func PPFromDistributedPublicParameters(dpp *DistPublicParameters) *PublicParameters {
	return &PublicParameters{
		N:             dpp.N,
		CurveID:       dpp.CurveID,
		P:             dpp.P[0],
		H:             dpp.H[0],
		FirstHalf:     dpp.P[1 : dpp.N+1],
		SecondHalf:    dpp.P[dpp.N+1:],
		FirstHalfInG2: dpp.H[1:],
	}
}

func DecryptionKeyFromDistPublicParameters(dpp *DistPublicParameters, index int, x *math.Zr) DecryptionKey {
	return dpp.T[index].Mul(x.PowMod(math.Curves[dpp.CurveID].NewZrFromInt(int64(index))))
}

func PublicKeyFromDistPublicParameters(dpp *DistPublicParameters) PublicKey {
	return dpp.T[0]
}

func computeZKProof(P, X *math.G1, x *math.Zr, curve *math.Curve) (*ZKProof, error) {
	// compute X^r
	rand, err := curve.Rand()
	if err != nil {
		return nil, err
	}
	r := curve.NewRandomZr(rand)
	R := P.Mul(r)
	chal := computeChallenge([]*math.G1{P, X, R}, curve)

	// compute Schnorr proof
	proof := curve.ModMul(x, chal, curve.GroupOrder)
	proof = curve.ModAdd(r, proof, curve.GroupOrder)

	return &ZKProof{
		Proof:     proof,
		Challenge: chal,
	}, nil
}

func verifyZKProof(P, X *math.G1, proof *ZKProof, curve *math.Curve) error {
	R := P.Mul(proof.Proof)
	R.Sub(X.Mul(proof.Challenge))
	if !computeChallenge([]*math.G1{P, X, R}, curve).Equals(proof.Challenge) {
		return errors.New("invalid ZK proof")
	}
	return nil
}

func computeChallenge(publicInput []*math.G1, curve *math.Curve) *math.Zr {
	var toHash []byte
	for i := 0; i < len(publicInput); i++ {
		toHash = append(toHash, publicInput[i].Bytes()...)
	}
	return curve.HashToZr(toHash)
}
