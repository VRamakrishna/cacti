/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// helper contains miscellaneous helper functions used throughout the code
package main

import (
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	log "github.com/sirupsen/logrus"
	math "github.com/IBM/mathlib"
)

const dbeObjectKey = "dbecrypto"
const dbeSecretKey = "secret"
const dbeInitSRSKey = "srsinit"
const dbeInitSRSOrgKey = "srsinitorg"
const dbeInitSRSStatusKey = "srsinitstatus"
const dbeUpdateSRSKey = "srsupdate"
const dbeUpdateSRSOrgKey = "srsupdateorg"
const dbeUpdateSRSStatusKey = "srsupdatestatus"
const dbeUpdateSRSLatestEntityIdKey = "srsupdatelatestentityid"
const dbeSRSProposed = "PROPOSED"
const dbeSRSValidated = "VALIDATED"

// getCollectionName is an internal helper function to get collection of submitting client identity.
func getCollectionName(ctx contractapi.TransactionContextInterface) (string, error) {

	// Get the MSP ID of the org to which this peer belongs
	peerMSPID, err := shim.GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed to get verified MSPID: %v", err)
	}

	// Create the collection name
	orgCollection := peerMSPID + "PrivateCollection"

	return orgCollection, nil
}

func recordSecretInPrivateCollection(ctx contractapi.TransactionContextInterface, secretBytes []byte) error {

	// Get collection name for this organization.
	orgCollection, err := getCollectionName(ctx)
	if err != nil {
		return fmt.Errorf("Failed to infer private collection name for the org: %v", err)
	}

	secretKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeSecretKey})
	log.Printf("Put: collection %s, key %s, value %s", orgCollection, secretKey, string(secretBytes))
	err = ctx.GetStub().PutPrivateData(orgCollection, secretKey, secretBytes)
	if err != nil {
		return fmt.Errorf("Failed to store secret for key %s in collection %s: %v", secretKey, orgCollection, err)
	}
	return nil
}

func (s *SmartContract) GenerateDbeInitVal(ctx contractapi.TransactionContextInterface, numOrgs int, seed string) error {
	// Check if an InitRequest is already recorded. If so, return.
	initRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for InitRequest: %+v", err)
	}
	initRequestBytes, err := ctx.GetStub().GetState(initRequestKey)
	if err != nil {
		return err
	}
	if initRequestBytes != nil && len(initRequestBytes) != 0 {
		return fmt.Errorf("Invalid transaction. InitRequest already recorded.")
	}

	// Record the serialized InitRequest
	dbeParams := &DistPublicParameters{}
	initRequest, err := dbeParams.Init(0, numOrgs, []byte(seed))
	if err != nil {
		return fmt.Errorf("Error computing initial SRS value: %+v", err)
	}

	// Serialize the InitRequest for recording
	initRequestBytes, err = marshalDBEInitVal(initRequest)
	if err != nil {
		return fmt.Errorf("Error marshalling the InitRequest object: %+v", err)
	}

	err = ctx.GetStub().PutState(initRequestKey, initRequestBytes)
	if err != nil {
		return fmt.Errorf("Error recording the InitRequest object on ledger: %+v", err)
	}

	// Record the Org MSPID of the peer creating this InitRequest
	initRequestOrgKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSOrgKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for InitRequest Org: %+v", err)
	}
	orgMSPID, err := shim.GetMSPID()
	if err != nil {
		return fmt.Errorf("Failed to get peer's Org MSPID: %+v", err)
	}
	err = ctx.GetStub().PutState(initRequestOrgKey, []byte(orgMSPID))
	if err != nil {
		return fmt.Errorf("Error recording the InitRequest Org: %+v", err)
	}

	// Record the status of the InitRequest
	initRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSStatusKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for InitRequest status: %+v", err)
	}
	return ctx.GetStub().PutState(initRequestStatusKey, []byte(dbeSRSProposed))
}

func (s *SmartContract) ValidateDbeInitVal(ctx contractapi.TransactionContextInterface) error {
	// Lookup the InitRequest recorded. If nothing recorded, return failure.
	initRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for InitRequest: %+v", err)
	}
	initRequestBytes, err := ctx.GetStub().GetState(initRequestKey)
	if err != nil {
		return err
	}
	if initRequestBytes == nil || len(initRequestBytes) == 0 {
		return fmt.Errorf("Invalid transaction. InitRequest not recorded yet.")
	}

	// Lookup the status. If it is 'VALIDATED`, return failure.
	initRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSStatusKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for InitRequest status: %+v", err)
	}
	initRequestStatusBytes, err := ctx.GetStub().GetState(initRequestStatusKey)
	if err != nil {
		return err
	}
	if initRequestStatusBytes == nil || len(initRequestStatusBytes) == 0 {
		return fmt.Errorf("Empty InitRequest status recorded on the ledger.")
	}
	if string(initRequestStatusBytes) == dbeSRSValidated {
		return fmt.Errorf("InitRequest already validated.")
	}

	// Unmarshal the InitRequest
	initRequest, err := unmarshalDBEInitVal(initRequestBytes)
	if err != nil {
		return err
	}

	// Validate the InitRequest
	initRequestParams, err := VerifyInit(initRequest)
	if err != nil {
		return err
	}
	if initRequestParams == nil {
		return fmt.Errorf("Init value verification failed.")
	}

	// Record the status of the InitRequest
	return ctx.GetStub().PutState(initRequestStatusKey, []byte(dbeSRSValidated))
}

func (s *SmartContract) GenerateDbeUpdateVal(ctx contractapi.TransactionContextInterface, entityId int) error {
	// Check if an UpdateRequest is already recorded for this entityId. If so, return.
	if entityId < 1 {
		return fmt.Errorf("Invalid entity ID %d. Must be >= 1", entityId)
	}
	entityIdStr := strconv.Itoa(entityId)
	previousEntityIdStr := strconv.Itoa(entityId - 1)
	updateRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, entityIdStr})
	if err != nil {
		return fmt.Errorf("Error creating composite key for UpdateRequest for entity %d: %+v", entityId, err)
	}
	updateRequestBytes, err := ctx.GetStub().GetState(updateRequestKey)
	if err != nil {
		return err
	}
	if updateRequestBytes != nil && len(updateRequestBytes) != 0 {
		return fmt.Errorf("Invalid transaction. UpdateRequest already recorded for entity %d.", entityId)
	}

	// Check if the org MSP ID trying to record an UpdateRequest is unique (i.e., it hasn't recorded one yet)
	orgMSPID, err := shim.GetMSPID()
	if err != nil {
		return fmt.Errorf("Failed to get peer's Org MSPID: %+v", err)
	}
	updateRequestOrgPresenceKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, orgMSPID})
	if err != nil {
		return fmt.Errorf("Error creating composite key for UpdateRequest for org MSP ID %s presence: %+v", orgMSPID, err)
	}
	updateRequestOrgPresenceBytes, err := ctx.GetStub().GetState(updateRequestOrgPresenceKey)
	if err != nil {
		return err
	}
	// We don't care what the value is as long as it isn't empty
	if updateRequestOrgPresenceBytes != nil && len(updateRequestOrgPresenceBytes) != 0 {
		return fmt.Errorf("Invalid transaction. UpdateRequest already recorded for org MSP ID %s.", orgMSPID)
	}

	// Lookup the previous UpdateRequest
	dbeParams := &DistPublicParameters{}
	if entityId == 1 {	// Lookup recorded InitRequest
		initRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSKey})
		if err != nil {
			return fmt.Errorf("Error creating composite key for InitRequest: %+v", err)
		}
		initRequestBytes, err := ctx.GetStub().GetState(initRequestKey)
		if err != nil {
			return err
		}
		if initRequestBytes == nil || len(initRequestBytes) == 0 {
			return fmt.Errorf("Invalid transaction. InitRequest not recorded yet.")
		}
		// Unmarshal the InitRequest
		initRequest, err := unmarshalDBEInitVal(initRequestBytes)
		if err != nil {
			return err
		}
		dbeParams = initRequest.InitDistPublicParameters
	} else {		// Lookup latest recorded UpdateRequest
		previousUpdateRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, previousEntityIdStr})
		if err != nil {
			return fmt.Errorf("Error creating composite key for UpdateRequest for entity %d: %+v", entityId - 1, err)
		}
		previousUpdateRequestBytes, err := ctx.GetStub().GetState(previousUpdateRequestKey)
		if err != nil {
			return err
		}
		if previousUpdateRequestBytes == nil || len(previousUpdateRequestBytes) == 0 {
			return fmt.Errorf("Invalid transaction. UpdateRequest not recorded for entity %d.", entityId - 1)
		}
		// Unmarshal the UpdateRequest
		previousUpdateRequest, err := unmarshalDBEUpdateVal(previousUpdateRequestBytes)
		if err != nil {
			return err
		}
		dbeParams = previousUpdateRequest.NewDistPublicParameters
	}

	// Generate a secret
	curve := math.Curves[dbeParams.CurveID]
	rand, err := curve.Rand()
	if err != nil {
		return err
	}
	secret := curve.NewRandomZr(rand)

	// Serialize the secret for recording
	secretBytes, err := marshalDBESecret(secret)
	if err != nil {
		return fmt.Errorf("Error marshalling the secret for entity %d: %+v", entityId, err)
	}

	// Record 'secret' in ths peer's org's PDC
	err = recordSecretInPrivateCollection(ctx, secretBytes)
	if err != nil {
		return err
	}

	// Create the new UpdateRequest
	updateRequest, err := dbeParams.Update(entityId, secret)
	if err != nil {
		return err
	}

	// Serialize the UpdateRequest for recording
	updateRequestBytes, err = marshalDBEUpdateVal(updateRequest)
	if err != nil {
		return fmt.Errorf("Error marshalling the UpdateRequest object for entity %d: %+v", entityId, err)
	}

	err = ctx.GetStub().PutState(updateRequestKey, updateRequestBytes)
	if err != nil {
		return fmt.Errorf("Error recording the UpdateRequest object for entity %d on ledger: %+v", entityId, err)
	}

	// Record the latest entityId on ledger for lookup
	updateRequestLatestEntityIdKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSLatestEntityIdKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for UpdateRequest latest entity Id %d: %+v", entityId, err)
	}
	err = ctx.GetStub().PutState(updateRequestLatestEntityIdKey, []byte(entityIdStr))
	if err != nil {
		return fmt.Errorf("Error recording the UpdateRequest latest entity Id %d on ledger: %+v", entityId, err)
	}

	// Record the Org MSPID of the peer creating this UpdateRequest
	err = ctx.GetStub().PutState(updateRequestOrgPresenceKey, []byte("true"))
	if err != nil {
		return err
	}
	updateRequestOrgKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSOrgKey, entityIdStr})
	if err != nil {
		return fmt.Errorf("Error creating composite key for UpdateRequest Org for entity %d: %+v", entityId, err)
	}
	err = ctx.GetStub().PutState(updateRequestOrgKey, []byte(orgMSPID))
	if err != nil {
		return fmt.Errorf("Error recording the UpdateRequest Org for entity %d: %+v", entityId, err)
	}

	// Record the status of the UpdateRequest
	updateRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSStatusKey, entityIdStr})
	if err != nil {
		return fmt.Errorf("Error creating composite key for UpdateRequest status for entity %d: %+v", entityId, err)
	}
	return ctx.GetStub().PutState(updateRequestStatusKey, []byte(dbeSRSProposed))
}

func (s *SmartContract) ValidateDbeUpdateVal(ctx contractapi.TransactionContextInterface) error {
	// Record the latest entityId on ledger for lookup
	updateRequestLatestEntityIdKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSLatestEntityIdKey})
	if err != nil {
		return fmt.Errorf("Error creating composite key for UpdateRequest latest entity Id: %+v", err)
	}
	latestEntityIdBytes, err := ctx.GetStub().GetState(updateRequestLatestEntityIdKey)
	if err != nil {
		return err
	}
	if latestEntityIdBytes == nil || len(latestEntityIdBytes) == 0 {
		return fmt.Errorf("Invalid transaction. No UpdateRequest recorded yet.")
	}
	latestEntityId, err := strconv.Atoi(string(latestEntityIdBytes))
	if err != nil {
		return err
	}
	log.Printf("Latest entity Id retrieved from ledger = %d.", latestEntityId)

	// TODO Lookup UpdateRequest corresponding to 'latestEntityId' and run 'VerifyUpdate' on it

	return nil
}

func marshalDBEInitVal(initRequest *InitRequest) ([]byte, error) {
	// TODO
	return nil, nil
}

func unmarshalDBEInitVal(initRequestBytes []byte) (*InitRequest, error) {
	// TODO
	return nil, nil
}

func marshalDBEUpdateVal(updateRequest *UpdateRequest) ([]byte, error) {
	// TODO
	return nil, nil
}

func unmarshalDBEUpdateVal(updateRequestBytes []byte) (*UpdateRequest, error) {
	// TODO
	return nil, nil
}

func marshalDBESecret(secret *math.Zr) ([]byte, error) {
	// TODO
	return nil, nil
}

func unmarshalDBESecret(secretBytes []byte) (*math.Zr, error) {
	// TODO
	return nil, nil
}
