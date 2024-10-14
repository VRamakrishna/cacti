/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// decoders contains all of our custom decoders to converting json `[]byte`s into structs.
// We are using customs decoders for this since the default Unmarshal function doesn't error
// when the json `[]byte` contains unknown fields
//
// There is a function for each struct because unfortulately Go doesn't have generics
package main

import (
	"encoding/base64"
	"encoding/json"
	"strings"

	"github.com/hyperledger/cacti/weaver/common/protos-go/v2/common"
	"github.com/hyperledger/cacti/weaver/common/protos-go/v2/identity"
	protoV2 "google.golang.org/protobuf/proto"
)

func decodeMembershipSerialized64(bytes64 string) (*common.Membership, error) {
	var decodeObj common.Membership
	protoBytes, err := base64.StdEncoding.DecodeString(bytes64)
	err = protoV2.Unmarshal(protoBytes, &decodeObj)
	if err != nil {
		return nil, logThenErrorf("Unable to unmarshal membership serialized proto")
	}
	return &decodeObj, nil
}

func decodeMembership(jsonBytes []byte) (*common.Membership, error) {
	var decodeObj common.Membership
	dec := json.NewDecoder(strings.NewReader(string(jsonBytes)))
	dec.DisallowUnknownFields()
	err := dec.Decode(&decodeObj)
	if err != nil {
		return nil, err
	}
	return &decodeObj, nil
}

func decodeCounterAttestedMembership(protoBytesBase64 string) (*identity.CounterAttestedMembership, error) {
	var decodeObj identity.CounterAttestedMembership
	protoBytes, err := base64.StdEncoding.DecodeString(protoBytesBase64)
	if err != nil {
		return nil, logThenErrorf("Counter attested membership could not be decoded from base64: %s", err.Error())
	}
	err = protoV2.Unmarshal(protoBytes, &decodeObj)
	if err != nil {
		return nil, logThenErrorf("Unable to unmarshal counter attested membership serialized proto")
	}
	return &decodeObj, nil
}

func decodeVerificationPolicy(jsonBytes []byte) (*common.VerificationPolicy, error) {
	var decodeObj common.VerificationPolicy
	dec := json.NewDecoder(strings.NewReader(string(jsonBytes)))
	dec.DisallowUnknownFields()
	err := dec.Decode(&decodeObj)
	if err != nil {
		return nil, err
	}
	return &decodeObj, nil
}

func decodeAccessControlPolicy(jsonBytes []byte) (*common.AccessControlPolicy, error) {
	var decodeObj common.AccessControlPolicy
	dec := json.NewDecoder(strings.NewReader(string(jsonBytes)))
	dec.DisallowUnknownFields()
	err := dec.Decode(&decodeObj)
	if err != nil {
		return nil, err
	}
	return &decodeObj, nil
}
