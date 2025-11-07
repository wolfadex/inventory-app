module Endpoints.Api.Items exposing
    ( get
    , post
    )

import Acadia.Serialize
import Backend
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


post : (Result Http.Extended.Error Backend.Item -> msg) -> Backend.AddItemInput -> Effect msg
post toMsg input =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Post
            , path = Endpoints.ApiItems
            , request = Serialize.toBytesEncoder Acadia.Serialize.addItemInput input
            , response = Serialize.toBytesDecoder Acadia.Serialize.addItemResponse
            }
        , onResponse = toMsg
        }


get : (Result Http.Extended.Error (List Backend.Item) -> msg) -> Backend.OrganizationID -> Effect msg
get toMsg input =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Get
            , path = Endpoints.ApiItems
            , request = Serialize.toBytesEncoder Acadia.Serialize.organizationID input
            , response = Serialize.toBytesDecoder Acadia.Serialize.getItemsResponse
            }
        , onResponse = toMsg
        }
