module Endpoints.ApiAuthLogout exposing (post)

import Acadia.Serialize
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


post : (Result Http.Extended.Error () -> msg) -> Effect msg
post toMsg =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Post
            , path = Endpoints.ApiAuthLogout
            , request = Serialize.toBytesEncoder Serialize.unit ()
            , response = Serialize.toBytesDecoder Acadia.Serialize.logoutResponse
            }
        , onResponse = toMsg
        }
