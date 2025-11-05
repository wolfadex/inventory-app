module Acadia.Api exposing
    ( Error(..)
    , authInfoCodec
    , createOrganizationCodec
    , errorCodec
    , getUserSelfCodec
    , loginCodec
    , logoutCodec
    , organizationCodec
    , signUpInfoCodec
    )

import Backend
import Serialize


type Error
    = Field { name : String, message : String }
    | Generic String


errorCodec : Serialize.Codec e Error
errorCodec =
    Serialize.customType
        (\fieldEncoder genericEncoder value ->
            case value of
                Field v ->
                    fieldEncoder v

                Generic v ->
                    genericEncoder v
        )
        |> Serialize.variant1 Field fieldErrorCodec
        |> Serialize.variant1 Generic Serialize.string
        |> Serialize.finishCustomType


fieldErrorCodec : Serialize.Codec e { name : String, message : String }
fieldErrorCodec =
    Serialize.record (\name message -> { name = name, message = message })
        |> Serialize.field .name Serialize.string
        |> Serialize.field .message Serialize.string
        |> Serialize.finishRecord


logoutCodec : Serialize.Codec e ()
logoutCodec =
    Serialize.unit


loginCodec : Serialize.Codec e ()
loginCodec =
    Serialize.unit


authInfoCodec : Serialize.Codec e Backend.AuthInfo
authInfoCodec =
    Serialize.record Backend.AuthInfo
        |> Serialize.field .email Serialize.string
        |> Serialize.field .password Serialize.string
        |> Serialize.finishRecord


signUpInfoCodec : Serialize.Codec e Backend.SignUpInfo
signUpInfoCodec =
    Serialize.record Backend.SignUpInfo
        |> Serialize.field .name Serialize.string
        |> Serialize.field .email Serialize.string
        |> Serialize.field .password Serialize.string
        |> Serialize.finishRecord


getUserSelfCodec : Serialize.Codec e ( Backend.User, Maybe Backend.Organization )
getUserSelfCodec =
    Serialize.tuple userCodec (Serialize.maybe organizationCodec)


userCodec : Serialize.Codec e Backend.User
userCodec =
    Serialize.record Backend.User
        |> Serialize.field .id userIdCodec
        |> Serialize.field .primaryEmail Serialize.string
        |> Serialize.finishRecord


userIdCodec : Serialize.Codec e Backend.UserID
userIdCodec =
    Serialize.customType (\enc (Backend.UserID val) -> enc val)
        |> Serialize.variant1 Backend.UserID Serialize.uuid
        |> Serialize.finishCustomType


organizationCodec : Serialize.Codec e Backend.Organization
organizationCodec =
    Serialize.record Backend.Organization
        |> Serialize.field .id organizationIdCodec
        |> Serialize.field .name Serialize.string
        |> Serialize.finishRecord


organizationIdCodec : Serialize.Codec e Backend.OrganizationID
organizationIdCodec =
    Serialize.customType (\enc (Backend.OrganizationID val) -> enc val)
        |> Serialize.variant1 Backend.OrganizationID Serialize.uuid
        |> Serialize.finishCustomType


createOrganizationCodec : Serialize.Codec e { name : String }
createOrganizationCodec =
    Serialize.record (\name -> { name = name })
        |> Serialize.field .name Serialize.string
        |> Serialize.finishRecord
