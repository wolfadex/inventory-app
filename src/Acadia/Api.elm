module Acadia.Api exposing
    ( authInfoCodec
    , authenticateCodec
    , createOrganizationCodec
    , getUserSelfCodec
    , organizationCodec
    , userCodec
    , userIdCodec
    )

import Backend
import Serialize


authenticateCodec : Serialize.Codec e ()
authenticateCodec =
    Serialize.unit


authInfoCodec : Serialize.Codec e Backend.AuthInfo
authInfoCodec =
    Serialize.record Backend.AuthInfo
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
