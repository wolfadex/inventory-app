module Endpoints.ApiAuthSignup exposing (post)

import Acadia.Serialize
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
            , request = Serialize.toBytesEncoder Acadia.Serialize.signUpInfo signupInfo
            , response = Serialize.toBytesDecoder Acadia.Serialize.signupResponse
            }
        , onResponse = toMsg
        }
