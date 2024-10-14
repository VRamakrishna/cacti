/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// helper contains miscellaneous helper functions used throughout the code
package main

import (
	"encoding/base64"
	"encoding/json"
	"os"
	"strconv"

	//"github.com/hyperledger/fabric-chaincode-go/pkg/statebased"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/cacti/weaver/common/protos-go/v2/common"
	log "github.com/sirupsen/logrus"
	math "github.com/IBM/mathlib"
	protoV2 "google.golang.org/protobuf/proto"
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

const dbeSecretFileName = "/home/chaincode/secret.dbe"
const dbeLocalOrgVersionFileName = "/home/chaincode/version.dbe"

/*// getCollectionName is an internal helper function to get collection of submitting client identity.
func getCollectionName(ctx contractapi.TransactionContextInterface) (string, error) {

	// Get the MSP ID of the org to which this peer belongs
	peerMSPID, err := shim.GetMSPID()
	if err != nil {
		return "", logThenErrorf("failed to get verified MSPID: %v", err)
	}

	// Create the collection name
	orgCollection := peerMSPID + "PrivateCollection"

	return orgCollection, nil
}

func recordSecretInPrivateCollection(ctx contractapi.TransactionContextInterface, secretBytes []byte) error {

	// Get collection name for this organization.
	orgCollection, err := getCollectionName(ctx)
	if err != nil {
		return logThenErrorf("Failed to infer private collection name for the org: %v", err)
	}

	secretKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeSecretKey})
	log.Printf("Put: collection %s, key %s, value %s", orgCollection, secretKey, string(secretBytes))
	err = ctx.GetStub().PutPrivateData(orgCollection, secretKey, secretBytes)
	if err != nil {
		return logThenErrorf("Failed to store secret for key %s in collection %s: %v", secretKey, orgCollection, err)
	}

	// Update the secret key state (in PDC) endorsement policy to require only the corresponding org's endorsement
	ep, err := statebased.NewStateEP(nil)
	if err != nil {
		return logThenErrorf("%v", err)
	}
	orgMSPID, err := shim.GetMSPID()
	if err != nil {
		return logThenErrorf("%v", err)
	}
	err = ep.AddOrgs(statebased.RoleTypeMember, []string{orgMSPID}...)
	if err != nil {
		return logThenErrorf("%v", err)
	}
	policy, err := ep.Policy()
	if err != nil {
		return logThenErrorf("%v", err)
	}
	err = ctx.GetStub().SetPrivateDataValidationParameter(orgCollection, secretKey, policy)
	if err != nil {
		return logThenErrorf("Failed to update endorsement policy for collection %s, secret key %s: %v", orgCollection, secretKey, err)
	}
	return nil
}*/

func recordSecretInFile(secretBytes []byte) error {

	log.Printf("Write secret: filename %s, value %s", dbeSecretFileName, string(secretBytes))
	_, err := os.Create(dbeSecretFileName)
	if err != nil {
		return logThenErrorf("Failed to create file %s to store secret key %s: %v", dbeSecretFileName, string(secretBytes), err)
	}
	err = os.WriteFile(dbeSecretFileName, secretBytes, 0644)
	if err != nil {
		return logThenErrorf("Failed to store secret %s in file %s: %v", string(secretBytes), dbeSecretFileName, err)
	}
	return nil
}

func (s *SmartContract) GenerateDbeInitVal(ctx contractapi.TransactionContextInterface, numOrgs int, seed string) error {
	// Check if an InitRequest is already recorded. If so, return.
	initRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for InitRequest: %+v", err)
	}
	initRequestBytes, err := ctx.GetStub().GetState(initRequestKey)
	if err != nil {
		return err
	}
	if initRequestBytes != nil && len(initRequestBytes) != 0 {
		return logThenErrorf("Invalid transaction. InitRequest already recorded.")
	}

	// Record the serialized InitRequest
	dbeParams := &DistPublicParameters{}
	initRequest, err := dbeParams.Init(0, numOrgs, []byte(seed))
	if err != nil {
		return logThenErrorf("Error computing initial SRS value: %+v", err)
	}

	// Serialize the InitRequest for recording
	initRequestBytes, err = marshalDBEInitVal(initRequest)
	if err != nil {
		return logThenErrorf("Error marshalling the InitRequest object: %+v", err)
	}

	err = ctx.GetStub().PutState(initRequestKey, initRequestBytes)
	if err != nil {
		return logThenErrorf("Error recording the InitRequest object on ledger: %+v", err)
	}

	// Record the Org MSPID of the peer creating this InitRequest
	initRequestOrgKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSOrgKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for InitRequest Org: %+v", err)
	}
	orgMSPID, err := shim.GetMSPID()
	if err != nil {
		return logThenErrorf("Failed to get peer's Org MSPID: %+v", err)
	}
	err = ctx.GetStub().PutState(initRequestOrgKey, []byte(orgMSPID))
	if err != nil {
		return logThenErrorf("Error recording the InitRequest Org: %+v", err)
	}

	// Record the status of the InitRequest
	initRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSStatusKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for InitRequest status: %+v", err)
	}
	return ctx.GetStub().PutState(initRequestStatusKey, []byte(dbeSRSProposed))
}

func (s *SmartContract) ValidateDbeInitVal(ctx contractapi.TransactionContextInterface) error {
	// Lookup the InitRequest recorded. If nothing recorded, return failure.
	initRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for InitRequest: %+v", err)
	}
	initRequestBytes, err := ctx.GetStub().GetState(initRequestKey)
	if err != nil {
		return err
	}
	if initRequestBytes == nil || len(initRequestBytes) == 0 {
		return logThenErrorf("Invalid transaction. InitRequest not recorded yet.")
	}

	// Lookup the status. If it is 'VALIDATED`, return failure.
	initRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSStatusKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for InitRequest status: %+v", err)
	}
	initRequestStatusBytes, err := ctx.GetStub().GetState(initRequestStatusKey)
	if err != nil {
		return err
	}
	if initRequestStatusBytes == nil || len(initRequestStatusBytes) == 0 {
		return logThenErrorf("Empty InitRequest status recorded on the ledger.")
	}
	if string(initRequestStatusBytes) == dbeSRSValidated {
		return logThenErrorf("InitRequest already validated.")
	}

	// Unmarshal the InitRequest
	initRequest, err := unmarshalDBEInitVal(initRequestBytes)
	if err != nil {
		return err
	}

	// Validate the InitRequest
	initRequestParams, err := VerifyInit(initRequest)
	if err != nil || initRequestParams == nil {
		var retErr error
		if err != nil {
			retErr = err
		} else {
			retErr = logThenErrorf("Init value verification failed.")
		}

		// Cleanup: delete some of the key value pairs if the validation fails (i.e., the init request recorded was invalid)
		err = ctx.GetStub().DelState(initRequestKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. InitRequest verification error: %+v", initRequestKey, err, retErr)
		}
		initRequestOrgKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSOrgKey})
		if err != nil {
			return logThenErrorf("Error creating composite key for InitRequest Org: %+v. InitRequest verification error: %+v", err, retErr)
		}
		err = ctx.GetStub().DelState(initRequestOrgKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. InitRequest verification error: %+v", initRequestOrgKey, err, retErr)
		}
		err = ctx.GetStub().DelState(initRequestStatusKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. InitRequest verification error: %+v", initRequestStatusKey, err, retErr)
		}

		return retErr
	}

	// Record the status of the InitRequest
	return ctx.GetStub().PutState(initRequestStatusKey, []byte(dbeSRSValidated))
}

func GetLastRequestDBEParams(ctx contractapi.TransactionContextInterface, entityId int) (*DistPublicParameters, error) {
	dbeParams := &DistPublicParameters{}
	if entityId == 1 {	// Lookup recorded InitRequest
		initRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeInitSRSKey})
		if err != nil {
			return nil, logThenErrorf("Error creating composite key for InitRequest: %+v", err)
		}
		initRequestBytes, err := ctx.GetStub().GetState(initRequestKey)
		if err != nil {
			return nil, err
		}
		if initRequestBytes == nil || len(initRequestBytes) == 0 {
			return nil, logThenErrorf("Invalid transaction. InitRequest not recorded yet.")
		}
		// Unmarshal the InitRequest
		initRequest, err := unmarshalDBEInitVal(initRequestBytes)
		if err != nil {
			return nil, err
		}
		dbeParams = initRequest.InitDistPublicParameters
	} else {		// Lookup latest recorded UpdateRequest
		previousEntityIdStr := strconv.Itoa(entityId - 1)
		previousUpdateRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, previousEntityIdStr})
		if err != nil {
			return nil, logThenErrorf("Error creating composite key for UpdateRequest for entity Id %d: %+v", entityId - 1, err)
		}
		previousUpdateRequestBytes, err := ctx.GetStub().GetState(previousUpdateRequestKey)
		if err != nil {
			return nil, err
		}
		if previousUpdateRequestBytes == nil || len(previousUpdateRequestBytes) == 0 {
			return nil, logThenErrorf("Invalid transaction. UpdateRequest not recorded for entity Id %d.", entityId - 1)
		}
		// Unmarshal the UpdateRequest
		previousUpdateRequest, err := unmarshalDBEUpdateVal(previousUpdateRequestBytes)
		if err != nil {
			return nil, err
		}
		dbeParams = previousUpdateRequest.NewDistPublicParameters
	}

	return dbeParams, nil
}

func (s *SmartContract) GenerateDbeUpdateVal(ctx contractapi.TransactionContextInterface, entityId int) error {
	// Check if an UpdateRequest is already recorded for this entityId. If so, return.
	if entityId < 1 {
		return logThenErrorf("Invalid entity ID %d. Must be >= 1", entityId)
	}
	entityIdStr := strconv.Itoa(entityId)
	updateRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, entityIdStr})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest for entity Id %d: %+v", entityId, err)
	}
	updateRequestBytes, err := ctx.GetStub().GetState(updateRequestKey)
	if err != nil {
		return err
	}
	if updateRequestBytes != nil && len(updateRequestBytes) != 0 {
		return logThenErrorf("Invalid transaction. UpdateRequest already recorded for entity Id %d.", entityId)
	}

	// Check if the org MSP ID trying to record an UpdateRequest is unique (i.e., it hasn't recorded one yet)
	orgMSPID, err := shim.GetMSPID()
	if err != nil {
		return logThenErrorf("Failed to get peer's Org MSPID: %+v", err)
	}
	updateRequestOrgPresenceKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, orgMSPID})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest for org MSP ID %s presence: %+v", orgMSPID, err)
	}
	updateRequestOrgPresenceBytes, err := ctx.GetStub().GetState(updateRequestOrgPresenceKey)
	if err != nil {
		return err
	}
	// The value should be the entityId (or the counter), but here we don't care what it is as long as it isn't empty
	if updateRequestOrgPresenceBytes != nil && len(updateRequestOrgPresenceBytes) != 0 {
		return logThenErrorf("Invalid transaction. UpdateRequest already recorded for org MSP ID %s.", orgMSPID)
	}

	// Lookup the previous UpdateRequest (or InitRequest) params
	dbeParams, err := GetLastRequestDBEParams(ctx, entityId)
	if err != nil {
		return err
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
		return logThenErrorf("Error marshalling the secret for entity Id %d: %+v", entityId, err)
	}

	// Record 'secret' in this peer's org's PDC
	//err = recordSecretInPrivateCollection(ctx, secretBytes)
	// Record 'secret' on the filesystem
	err = recordSecretInFile(secretBytes)
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
		return logThenErrorf("Error marshalling the UpdateRequest object for entity Id %d: %+v", entityId, err)
	}

	err = ctx.GetStub().PutState(updateRequestKey, updateRequestBytes)
	if err != nil {
		return logThenErrorf("Error recording the UpdateRequest object for entity Id %d on ledger: %+v", entityId, err)
	}

	// Record the latest entityId on ledger for lookup
	updateRequestLatestEntityIdKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSLatestEntityIdKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest latest entity Id %d: %+v", entityId, err)
	}
	err = ctx.GetStub().PutState(updateRequestLatestEntityIdKey, []byte(entityIdStr))
	if err != nil {
		return logThenErrorf("Error recording the UpdateRequest latest entity Id %d on ledger: %+v", entityId, err)
	}

	// Record the Org MSPID and version number of the peer creating this UpdateRequest
	err = ctx.GetStub().PutState(updateRequestOrgPresenceKey, []byte(entityIdStr))
	if err != nil {
		return err
	}
	_, err = os.Create(dbeLocalOrgVersionFileName)
	if err != nil {
		return logThenErrorf("Failed to create file %s to store local Org version: %v", dbeLocalOrgVersionFileName, err)
	}
	err = os.WriteFile(dbeLocalOrgVersionFileName, []byte(entityIdStr), 0644)
	if err != nil {
		return logThenErrorf("Failed to store local org version in file %s: %v", dbeLocalOrgVersionFileName, err)
	}
	updateRequestOrgKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSOrgKey, entityIdStr})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest Org for entity Id %d: %+v", entityId, err)
	}
	err = ctx.GetStub().PutState(updateRequestOrgKey, []byte(orgMSPID))
	if err != nil {
		return logThenErrorf("Error recording the UpdateRequest Org for entity Id %d: %+v", entityId, err)
	}

	// Record the status of the UpdateRequest
	updateRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSStatusKey, entityIdStr})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest status for entity Id %d: %+v", entityId, err)
	}
	return ctx.GetStub().PutState(updateRequestStatusKey, []byte(dbeSRSProposed))
}

func (s *SmartContract) ValidateDbeUpdateVal(ctx contractapi.TransactionContextInterface) error {
	// Read the latest entityId on ledger
	updateRequestLatestEntityIdKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSLatestEntityIdKey})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest latest entity Id: %+v", err)
	}
	latestEntityIdBytes, err := ctx.GetStub().GetState(updateRequestLatestEntityIdKey)
	if err != nil {
		return err
	}
	if latestEntityIdBytes == nil || len(latestEntityIdBytes) == 0 {
		return logThenErrorf("Invalid transaction. No UpdateRequest recorded yet.")
	}
	latestEntityIdStr := string(latestEntityIdBytes)
	latestEntityId, err := strconv.Atoi(latestEntityIdStr)
	if err != nil {
		return err
	}
	log.Printf("Latest entity Id retrieved from ledger = %d.", latestEntityId)

	// Lookup UpdateRequest corresponding to 'latestEntityId'
	updateRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, latestEntityIdStr})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest for latest entity Id %d: %+v", latestEntityId, err)
	}
	updateRequestBytes, err := ctx.GetStub().GetState(updateRequestKey)
	if err != nil {
		return err
	}
	if updateRequestBytes == nil || len(updateRequestBytes) == 0 {
		return logThenErrorf("Invalid ledger state. UpdateRequest not recorded for latest entity Id %d.", latestEntityId)
	}

	// Lookup the status. If it is 'VALIDATED`, return failure.
	updateRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSStatusKey, latestEntityIdStr})
	if err != nil {
		return logThenErrorf("Error creating composite key for UpdateRequest status for entity Id %d: %+v", latestEntityId, err)
	}
	updateRequestStatusBytes, err := ctx.GetStub().GetState(updateRequestStatusKey)
	if err != nil {
		return err
	}
	if updateRequestStatusBytes == nil || len(updateRequestStatusBytes) == 0 {
		return logThenErrorf("Empty UpdateRequest status recorded on the ledger for entity Id %d.", latestEntityId)
	}
	if string(updateRequestStatusBytes) == dbeSRSValidated {
		return logThenErrorf("UpdateRequest already validated.")
	}

	// Lookup the previous UpdateRequest (or InitRequest) params
	oldDBEParams, err := GetLastRequestDBEParams(ctx, latestEntityId)
	if err != nil {
		return err
	}

	// Unmarshal the UpdateRequest
	updateRequest, err := unmarshalDBEUpdateVal(updateRequestBytes)
	if err != nil {
		return err
	}

	// Validate the UpdateRequest
	updateRequestParams, err := VerifyUpdate(oldDBEParams, updateRequest)
	if err != nil || updateRequestParams == nil {
		var retErr error
		if err != nil {
			retErr = err
		} else {
			retErr = logThenErrorf("Init value verification failed.")
		}

		// Cleanup: delete some of the key value pairs if the validation fails (i.e., the update request recorded was invalid)
		err = ctx.GetStub().DelState(updateRequestKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. UpdateRequest verification error: %+v", updateRequestKey, err, retErr)
		}
		updateRequestOrgKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSOrgKey, latestEntityIdStr})
		if err != nil {
			return logThenErrorf("Error creating composite key for UpdateRequest Org for entity Id %d: %+v. UpdateRequest verification error: %+v", latestEntityId, err, retErr)
		}
		orgMSPIDBytes, err := ctx.GetStub().GetState(updateRequestOrgKey)
		if err != nil {
			return logThenErrorf("Error reading key %s: %+v. UpdateRequest verification error: %+v", updateRequestOrgKey, err, retErr)
		}
		err = ctx.GetStub().DelState(updateRequestOrgKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. UpdateRequest verification error: %+v", updateRequestOrgKey, err, retErr)
		}
		updateRequestOrgPresenceKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, string(orgMSPIDBytes)})
		if err != nil {
			return logThenErrorf("Error creating composite key for UpdateRequest for org MSP ID %s presence: %+v. UpdateRequest verification error: %+v", string(orgMSPIDBytes), err, retErr)
		}
		err = ctx.GetStub().DelState(updateRequestOrgPresenceKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. UpdateRequest verification error: %+v", updateRequestOrgPresenceKey, err, retErr)
		}
		previousEntityIdStr := strconv.Itoa(latestEntityId - 1)
		if latestEntityId > 1 {
			err = ctx.GetStub().PutState(updateRequestLatestEntityIdKey, []byte(previousEntityIdStr))
			if err != nil {
				return logThenErrorf("Error replacing key %s: %+v. UpdateRequest verification error: %+v", updateRequestLatestEntityIdKey, err, retErr)
			}
		} else {
			err = ctx.GetStub().DelState(updateRequestLatestEntityIdKey)
			if err != nil {
				return logThenErrorf("Error deleting key %s: %+v. UpdateRequest verification error: %+v", updateRequestLatestEntityIdKey, err, retErr)
			}
		}
		err = ctx.GetStub().DelState(updateRequestStatusKey)
		if err != nil {
			return logThenErrorf("Error deleting key %s: %+v. UpdateRequest verification error: %+v", updateRequestStatusKey, err, retErr)
		}

		return retErr
	}

	return ctx.GetStub().PutState(updateRequestStatusKey, []byte(dbeSRSValidated))
}

// Get latest SRS public parameters and latest version ID
// Return as a base64-encoded string from an unmarshalled DBEKey structure
func (s *SmartContract) GetDbeUpdatePublicParams(ctx contractapi.TransactionContextInterface) (string, error) {
	// Read the latest entityId on ledger
	updateRequestLatestEntityIdKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSLatestEntityIdKey})
	if err != nil {
		return "", logThenErrorf("Error creating composite key for UpdateRequest latest entity Id: %+v", err)
	}
	latestEntityIdBytes, err := ctx.GetStub().GetState(updateRequestLatestEntityIdKey)
	if err != nil {
		return "", err
	}
	if latestEntityIdBytes == nil || len(latestEntityIdBytes) == 0 {
		return "", logThenErrorf("Invalid transaction. No UpdateRequest recorded yet.")
	}
	latestEntityIdStr := string(latestEntityIdBytes)
	latestEntityId, err := strconv.Atoi(latestEntityIdStr)
	if err != nil {
		return "", err
	}
	log.Printf("Latest entity Id retrieved from ledger = %d.", latestEntityId)

	// Lookup UpdateRequest corresponding to 'latestEntityId'
	updateRequestKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, latestEntityIdStr})
	if err != nil {
		return "", logThenErrorf("Error creating composite key for UpdateRequest for latest entity Id %d: %+v", latestEntityId, err)
	}
	updateRequestBytes, err := ctx.GetStub().GetState(updateRequestKey)
	if err != nil {
		return "", err
	}
	if updateRequestBytes == nil || len(updateRequestBytes) == 0 {
		return "", logThenErrorf("Invalid ledger state. UpdateRequest not recorded for latest entity Id %d.", latestEntityId)
	}

	// Lookup the status.
	updateRequestStatusKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSStatusKey, latestEntityIdStr})
	if err != nil {
		return "", logThenErrorf("Error creating composite key for UpdateRequest status for entity Id %d: %+v", latestEntityId, err)
	}
	updateRequestStatusBytes, err := ctx.GetStub().GetState(updateRequestStatusKey)
	if err != nil {
		return "", err
	}
	if updateRequestStatusBytes == nil || len(updateRequestStatusBytes) == 0 {
		return "", logThenErrorf("Empty UpdateRequest status recorded on the ledger for entity Id %d.", latestEntityId)
	}

	var dbeUpdateInfo *common.DBEKey
	// If status is 'VALIDATED`, return the parameters for the update request fetched above.
	if string(updateRequestStatusBytes) == dbeSRSValidated {
		// Unmarshal 'updateRequestBytes' to 'updateRequest'
		updateRequest, err := unmarshalDBEUpdateVal(updateRequestBytes)
		if err != nil {
			return "", err
		}
		// Marshal updateRequest.NewDistPublicParameters to a byte array
		updateRequestParamsBytes, err := marshalDistPublicParameters(updateRequest.NewDistPublicParameters)
		if err != nil {
			return "", err
		}
		// Use DBEKey structure to encapsulate the above parameters plus 'latestEntityId'
		dbeUpdateInfo = &common.DBEKey{Srs: updateRequestParamsBytes, Version: uint32(latestEntityId)}
	} else {
		// The latest update request has not been validated, so fetch the previous one corresponding to 'latestEntityId' - 1
		log.Printf("Fetching previous entity Id %d from ledger as the latest one is not validated yet.", latestEntityId - 1)

		// If 'latestEntityId' <= 1, return error
		if latestEntityId <= 1 {
			return "", logThenErrorf("No UpdateRequest validated on ledger yet")
		}
		lastUpdateRequestParams, err := GetLastRequestDBEParams(ctx, latestEntityId)
		if err != nil {
			return "", err
		}
		// Marshal updateRequest.NewDistPublicParameters to a byte array
		lastUpdateRequestParamsBytes, err := marshalDistPublicParameters(lastUpdateRequestParams)
		if err != nil {
			return "", err
		}
		// Use DBEKey structure to encapsulate the above parameters plus 'latestEntityId'
		dbeUpdateInfo = &common.DBEKey{Srs: lastUpdateRequestParamsBytes, Version: uint32(latestEntityId -1)}
	}
	dbeUpdateInfoBytes, err := protoV2.Marshal(dbeUpdateInfo)
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(dbeUpdateInfoBytes), nil
}

// Read my org's version number as set in this protocol (i.e., in what position in the sequence did I submit an UpdateRequest)
func GetDbeUpdateLocalVersion(ctx contractapi.TransactionContextInterface) (int, error) {
	// Get my org MSP ID
	/*orgMSPID, err := shim.GetMSPID()
	if err != nil {
		return 0, logThenErrorf("Failed to get peer's Org MSPID: %+v", err)
	}
	// Lookup the version number corresponding to my org's position in the update sequence
	updateRequestOrgPresenceKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeUpdateSRSKey, orgMSPID})
	if err != nil {
		return 0, logThenErrorf("Error creating composite key for UpdateRequest for org MSP ID %s presence: %+v", orgMSPID, err)
	}
	updateRequestOrgPresenceBytes, err := ctx.GetStub().GetState(updateRequestOrgPresenceKey)
	if err != nil {
		return 0, err
	}*/
	updateRequestOrgPresenceBytes, err := os.ReadFile(dbeLocalOrgVersionFileName)
	if err != nil {
		return 0, logThenErrorf("Failed to fetch local Org version from file %s: %v", dbeLocalOrgVersionFileName, err)
	}
	entityId, err := strconv.Atoi(string(updateRequestOrgPresenceBytes))
	if err != nil {
		return 0, err
	}
	return entityId, nil
}

// Function: Read secret key from PDC
func GetSecretKey(ctx contractapi.TransactionContextInterface) (*math.Zr, error) {
	/*// Get collection name for my organization.
	orgCollection, err := getCollectionName(ctx)
	if err != nil {
		return nil, logThenErrorf("Failed to infer private collection name for the org: %v", err)
	}

	// Read the serialized secret key from the collection (see func recordSecretInPrivateCollection for the write counterpart)
	secretKey, err := ctx.GetStub().CreateCompositeKey(dbeObjectKey, []string{dbeSecretKey})
	secretBytes, err := ctx.GetStub().GetPrivateData(orgCollection, secretKey)
	log.Printf("Get: collection %s, key %s, value %s", orgCollection, secretKey, string(secretBytes))*/

	// Read the serialized secret key from the file system (see func recordSecretInFile for the write counterpart)
	secretBytes, err := os.ReadFile(dbeSecretFileName)
	if err != nil {
		return nil, logThenErrorf("Failed to fetch secret from file %s: %v", dbeSecretFileName, err)
	}
	log.Printf("Read secret from file: file name %s, value %s", dbeSecretFileName, string(secretBytes))

	// Unmarshal the secret key byte array using func unmarshalDBESecret and return it
	secret, err := unmarshalDBESecret(secretBytes)
	if err != nil {
		return nil, err
	}
	return secret, nil
}

func marshalDBEInitVal(initRequest *InitRequest) ([]byte, error) {
	return json.Marshal(initRequest)
}

func unmarshalDBEInitVal(initRequestBytes []byte) (*InitRequest, error) {
	initRequest := &InitRequest{}
	err := json.Unmarshal(initRequestBytes, initRequest)
	if err != nil {
		return nil, err
	} else {
		return initRequest, nil
	}
}

func marshalDBEUpdateVal(updateRequest *UpdateRequest) ([]byte, error) {
	return json.Marshal(updateRequest)
}

func unmarshalDBEUpdateVal(updateRequestBytes []byte) (*UpdateRequest, error) {
	updateRequest := &UpdateRequest{}
	err := json.Unmarshal(updateRequestBytes, updateRequest)
	if err != nil {
		return nil, err
	} else {
		return updateRequest, nil
	}
}

func marshalDBESecret(secret *math.Zr) ([]byte, error) {
	return secret.MarshalJSON()
}

func unmarshalDBESecret(secretBytes []byte) (*math.Zr, error) {
	secret := &math.Zr{}
	err := secret.UnmarshalJSON(secretBytes)
	if err != nil {
		return nil, err
	} else {
		return secret, nil
	}
}

func marshalDistPublicParameters(dpp *DistPublicParameters) ([]byte, error) {
	return json.Marshal(dpp)
}

func unmarshalDistPublicParameters(dppBytes []byte) (*DistPublicParameters, error) {
	dpp := &DistPublicParameters{}
	err := json.Unmarshal(dppBytes, dpp)
	if err != nil {
		return nil, err
	} else {
		return dpp, nil
	}
}
