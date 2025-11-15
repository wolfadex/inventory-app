module Endpoints.ApiAuthLogin exposing (post)

import Acadia.Serialize
import Backend
import Dict
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


post : (Result Http.Extended.Error () -> msg) -> Backend.AuthInfo -> Effect msg
post toMsg authInfo =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Post
            , path = Endpoints.ApiAuthLogin
            , queryParams = Dict.empty
            , request = Serialize.toBytesEncoder Acadia.Serialize.authInfo authInfo
            , response = Serialize.toBytesDecoder Acadia.Serialize.loginResponse
            }
        , onResponse = toMsg
        }
