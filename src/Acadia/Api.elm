module Acadia.Api exposing (authenticateCodec)

import Backend
import Serialize


authenticateCodec : Serialize.Codec e Backend.AuthInfo
authenticateCodec =
    Serialize.record Backend.AuthInfo
        |> Serialize.field .email Serialize.string
        |> Serialize.field .password Serialize.string
        |> Serialize.finishRecord
