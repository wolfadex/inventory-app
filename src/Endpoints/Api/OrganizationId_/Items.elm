module Endpoints.Api.OrganizationId_.Items exposing
    ( get
    , post
    )

import Acadia.Serialize
import Backend
import Dict
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
            , path = Endpoints.ApiOrganizationId_Items { organizationID = input.organizationID }
            , queryParams = Dict.empty
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
            , path = Endpoints.ApiOrganizationId_Items { organizationID = input }
            , queryParams = Dict.singleton "orgid" (Serialize.encodeToString Acadia.Serialize.organizationID input)
            , request = Serialize.toBytesEncoder Acadia.Serialize.organizationID input
            , response = Serialize.toBytesDecoder Acadia.Serialize.getItemsResponse
            }
        , onResponse = toMsg
        }
