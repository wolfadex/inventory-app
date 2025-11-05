module Acadia.Api exposing
    ( authInfoCodec
    , createOrganizationCodec
    , getUserSelfCodec
    , loginCodec
    , logoutCodec
    , organizationCodec
    , signUpInfoCodec
    )

import Backend
import Serialize


logoutCodec : Serialize.Codec ()
logoutCodec =
    Serialize.unit


loginCodec : Serialize.Codec ()
loginCodec =
    Serialize.unit


authInfoCodec : Serialize.Codec Backend.AuthInfo
authInfoCodec =
    Serialize.record Backend.AuthInfo
        |> Serialize.field .email Serialize.string
        |> Serialize.field .password Serialize.string
        |> Serialize.finishRecord


signUpInfoCodec : Serialize.Codec Backend.SignUpInfo
signUpInfoCodec =
    Serialize.record Backend.SignUpInfo
        |> Serialize.field .name Serialize.string
        |> Serialize.field .email Serialize.string
        |> Serialize.field .password Serialize.string
        |> Serialize.finishRecord


getUserSelfCodec : Serialize.Codec ( Backend.User, Maybe Backend.Organization )
getUserSelfCodec =
    Serialize.tuple userCodec (Serialize.maybe organizationCodec)


userCodec : Serialize.Codec Backend.User
userCodec =
    Serialize.record Backend.User
        |> Serialize.field .id userIdCodec
        |> Serialize.field .primaryEmail Serialize.string
        |> Serialize.finishRecord


userIdCodec : Serialize.Codec Backend.UserID
userIdCodec =
    Serialize.customType (\enc (Backend.UserID val) -> enc val)
        |> Serialize.variant1 Backend.UserID Serialize.uuid
        |> Serialize.finishCustomType


organizationCodec : Serialize.Codec Backend.Organization
organizationCodec =
    Serialize.record Backend.Organization
        |> Serialize.field .id organizationIdCodec
        |> Serialize.field .name Serialize.string
        |> Serialize.finishRecord


organizationIdCodec : Serialize.Codec Backend.OrganizationID
organizationIdCodec =
    Serialize.customType (\enc (Backend.OrganizationID val) -> enc val)
        |> Serialize.variant1 Backend.OrganizationID Serialize.uuid
        |> Serialize.finishCustomType


createOrganizationCodec : Serialize.Codec { name : String }
createOrganizationCodec =
    Serialize.record (\name -> { name = name })
        |> Serialize.field .name Serialize.string
        |> Serialize.finishRecord
