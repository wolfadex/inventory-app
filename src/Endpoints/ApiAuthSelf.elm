module Endpoints.ApiAuthSelf exposing (post)

import Acadia.Api
import Backend
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


post : (Result Http.Extended.Error ( Backend.User, Maybe Backend.Organization ) -> msg) -> Effect msg
post toMsg =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Post
            , path = Endpoints.ApiAuthSelf
            , request = Serialize.toBytesEncoder Serialize.unit ()
            , response = Serialize.toBytesDecoder Acadia.Api.getUserSelfResponseCodec
            }
        , onResponse = toMsg
        }
