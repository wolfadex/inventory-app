module Endpoints.ApiAuthLogin exposing (post)

import Acadia.Api
import Backend
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
            , request = Serialize.toBytesEncoder Acadia.Api.authInfoCodec authInfo
            , response = Serialize.toBytesDecoder Acadia.Api.loginResponseCodec
            }
        , onResponse = toMsg
        }
