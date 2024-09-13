// This file is @generated by prost-build.
#[derive(serde::Serialize, serde::Deserialize)]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct DbeKey {
    #[prost(bytes = "vec", tag = "1")]
    pub srs: ::prost::alloc::vec::Vec<u8>,
    #[prost(uint32, tag = "2")]
    pub version: u32,
}
#[derive(serde::Serialize, serde::Deserialize)]
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct EncryptionInfo {
    #[prost(enumeration = "EncryptionMechanism", tag = "1")]
    pub mechanism: i32,
    /// Either:
    ///     (1) a serialized X.509 certificate, if 'encryptionMechanism' == 'ECIES', or
    ///     (2) a base64 encoding of an SRS structure as 'DBEKey', if 'encryptionMechanism' == 'DBE'
    #[prost(bytes = "vec", tag = "2")]
    pub key: ::prost::alloc::vec::Vec<u8>,
}
#[derive(serde::Serialize, serde::Deserialize)]
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash, PartialOrd, Ord, ::prost::Enumeration)]
#[repr(i32)]
pub enum EncryptionMechanism {
    Ecies = 0,
    Dbe = 1,
}
impl EncryptionMechanism {
    /// String value of the enum field names used in the ProtoBuf definition.
    ///
    /// The values are not transformed in any way and thus are considered stable
    /// (if the ProtoBuf definition does not change) and safe for programmatic use.
    pub fn as_str_name(&self) -> &'static str {
        match self {
            EncryptionMechanism::Ecies => "ECIES",
            EncryptionMechanism::Dbe => "DBE",
        }
    }
    /// Creates an enum from field names used in the ProtoBuf definition.
    pub fn from_str_name(value: &str) -> ::core::option::Option<Self> {
        match value {
            "ECIES" => Some(Self::Ecies),
            "DBE" => Some(Self::Dbe),
            _ => None,
        }
    }
}
