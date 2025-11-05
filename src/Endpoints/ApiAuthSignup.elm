module Endpoints.ApiAuthSignup exposing (post)

import Acadia.Api
import Backend
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


post : (Result Http.Extended.Error () -> msg) -> Backend.SignUpInfo -> Effect msg
post toMsg signupInfo =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Post
            , path = Endpoints.ApiAuthSignup
            , request = Serialize.toBytesEncoder Acadia.Api.signUpInfoCodec signupInfo
            , response = Serialize.toBytesDecoder Acadia.Api.loginCodec
            }
        , onResponse = toMsg
        }
