/**
 * Generated by the protoc-gen-ts.  DO NOT EDIT!
 * compiler version: 3.19.1
 * source: models/run_transaction_request_pb.proto
 * git: https://github.com/thesayyn/protoc-gen-ts */
import * as dependency_1 from "./../google/protobuf/any";
import * as dependency_2 from "./besu_private_transaction_config_pb";
import * as dependency_3 from "./besu_transaction_config_pb";
import * as dependency_4 from "./consistency_strategy_pb";
import * as dependency_5 from "./web3_signing_credential_pb";
import * as pb_1 from "google-protobuf";
export namespace org.hyperledger.cacti.plugin.ledger.connector.besu {
    export class RunTransactionRequestPB extends pb_1.Message {
        #one_of_decls: number[][] = [];
        constructor(data?: any[] | {
            web3SigningCredential?: dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB;
            transactionConfig?: dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB;
            consistencyStrategy?: dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB;
            privateTransactionConfig?: dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB;
        }) {
            super();
            pb_1.Message.initialize(this, Array.isArray(data) ? data : [], 0, -1, [], this.#one_of_decls);
            if (!Array.isArray(data) && typeof data == "object") {
                if ("web3SigningCredential" in data && data.web3SigningCredential != undefined) {
                    this.web3SigningCredential = data.web3SigningCredential;
                }
                if ("transactionConfig" in data && data.transactionConfig != undefined) {
                    this.transactionConfig = data.transactionConfig;
                }
                if ("consistencyStrategy" in data && data.consistencyStrategy != undefined) {
                    this.consistencyStrategy = data.consistencyStrategy;
                }
                if ("privateTransactionConfig" in data && data.privateTransactionConfig != undefined) {
                    this.privateTransactionConfig = data.privateTransactionConfig;
                }
            }
        }
        get web3SigningCredential() {
            return pb_1.Message.getWrapperField(this, dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB, 451211679) as dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB;
        }
        set web3SigningCredential(value: dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB) {
            pb_1.Message.setWrapperField(this, 451211679, value);
        }
        get has_web3SigningCredential() {
            return pb_1.Message.getField(this, 451211679) != null;
        }
        get transactionConfig() {
            return pb_1.Message.getWrapperField(this, dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB, 478618563) as dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB;
        }
        set transactionConfig(value: dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB) {
            pb_1.Message.setWrapperField(this, 478618563, value);
        }
        get has_transactionConfig() {
            return pb_1.Message.getField(this, 478618563) != null;
        }
        get consistencyStrategy() {
            return pb_1.Message.getWrapperField(this, dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB, 86789548) as dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB;
        }
        set consistencyStrategy(value: dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB) {
            pb_1.Message.setWrapperField(this, 86789548, value);
        }
        get has_consistencyStrategy() {
            return pb_1.Message.getField(this, 86789548) != null;
        }
        get privateTransactionConfig() {
            return pb_1.Message.getWrapperField(this, dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB, 276796542) as dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB;
        }
        set privateTransactionConfig(value: dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB) {
            pb_1.Message.setWrapperField(this, 276796542, value);
        }
        get has_privateTransactionConfig() {
            return pb_1.Message.getField(this, 276796542) != null;
        }
        static fromObject(data: {
            web3SigningCredential?: ReturnType<typeof dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB.prototype.toObject>;
            transactionConfig?: ReturnType<typeof dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB.prototype.toObject>;
            consistencyStrategy?: ReturnType<typeof dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB.prototype.toObject>;
            privateTransactionConfig?: ReturnType<typeof dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB.prototype.toObject>;
        }): RunTransactionRequestPB {
            const message = new RunTransactionRequestPB({});
            if (data.web3SigningCredential != null) {
                message.web3SigningCredential = dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB.fromObject(data.web3SigningCredential);
            }
            if (data.transactionConfig != null) {
                message.transactionConfig = dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB.fromObject(data.transactionConfig);
            }
            if (data.consistencyStrategy != null) {
                message.consistencyStrategy = dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB.fromObject(data.consistencyStrategy);
            }
            if (data.privateTransactionConfig != null) {
                message.privateTransactionConfig = dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB.fromObject(data.privateTransactionConfig);
            }
            return message;
        }
        toObject() {
            const data: {
                web3SigningCredential?: ReturnType<typeof dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB.prototype.toObject>;
                transactionConfig?: ReturnType<typeof dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB.prototype.toObject>;
                consistencyStrategy?: ReturnType<typeof dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB.prototype.toObject>;
                privateTransactionConfig?: ReturnType<typeof dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB.prototype.toObject>;
            } = {};
            if (this.web3SigningCredential != null) {
                data.web3SigningCredential = this.web3SigningCredential.toObject();
            }
            if (this.transactionConfig != null) {
                data.transactionConfig = this.transactionConfig.toObject();
            }
            if (this.consistencyStrategy != null) {
                data.consistencyStrategy = this.consistencyStrategy.toObject();
            }
            if (this.privateTransactionConfig != null) {
                data.privateTransactionConfig = this.privateTransactionConfig.toObject();
            }
            return data;
        }
        serialize(): Uint8Array;
        serialize(w: pb_1.BinaryWriter): void;
        serialize(w?: pb_1.BinaryWriter): Uint8Array | void {
            const writer = w || new pb_1.BinaryWriter();
            if (this.has_web3SigningCredential)
                writer.writeMessage(451211679, this.web3SigningCredential, () => this.web3SigningCredential.serialize(writer));
            if (this.has_transactionConfig)
                writer.writeMessage(478618563, this.transactionConfig, () => this.transactionConfig.serialize(writer));
            if (this.has_consistencyStrategy)
                writer.writeMessage(86789548, this.consistencyStrategy, () => this.consistencyStrategy.serialize(writer));
            if (this.has_privateTransactionConfig)
                writer.writeMessage(276796542, this.privateTransactionConfig, () => this.privateTransactionConfig.serialize(writer));
            if (!w)
                return writer.getResultBuffer();
        }
        static deserialize(bytes: Uint8Array | pb_1.BinaryReader): RunTransactionRequestPB {
            const reader = bytes instanceof pb_1.BinaryReader ? bytes : new pb_1.BinaryReader(bytes), message = new RunTransactionRequestPB();
            while (reader.nextField()) {
                if (reader.isEndGroup())
                    break;
                switch (reader.getFieldNumber()) {
                    case 451211679:
                        reader.readMessage(message.web3SigningCredential, () => message.web3SigningCredential = dependency_5.org.hyperledger.cacti.plugin.ledger.connector.besu.Web3SigningCredentialPB.deserialize(reader));
                        break;
                    case 478618563:
                        reader.readMessage(message.transactionConfig, () => message.transactionConfig = dependency_3.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuTransactionConfigPB.deserialize(reader));
                        break;
                    case 86789548:
                        reader.readMessage(message.consistencyStrategy, () => message.consistencyStrategy = dependency_4.org.hyperledger.cacti.plugin.ledger.connector.besu.ConsistencyStrategyPB.deserialize(reader));
                        break;
                    case 276796542:
                        reader.readMessage(message.privateTransactionConfig, () => message.privateTransactionConfig = dependency_2.org.hyperledger.cacti.plugin.ledger.connector.besu.BesuPrivateTransactionConfigPB.deserialize(reader));
                        break;
                    default: reader.skipField();
                }
            }
            return message;
        }
        serializeBinary(): Uint8Array {
            return this.serialize();
        }
        static deserializeBinary(bytes: Uint8Array): RunTransactionRequestPB {
            return RunTransactionRequestPB.deserialize(bytes);
        }
    }
}
