module Endpoints.Api.Items.Id_ exposing
    ( delete
    , get
    )

import Acadia.Serialize
import Backend
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


get : (Result Http.Extended.Error Backend.Item -> msg) -> Backend.GetItemInput -> Effect msg
get toMsg input =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Get
            , path = Endpoints.ApiItems
            , request = Serialize.toBytesEncoder Acadia.Serialize.getItemInput input
            , response = Serialize.toBytesDecoder Acadia.Serialize.getItemResponse
            }
        , onResponse = toMsg
        }


delete : (Result Http.Extended.Error () -> msg) -> Backend.DeleteItemInput -> Effect msg
delete toMsg input =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Delete
            , path = Endpoints.ApiItems
            , request = Serialize.toBytesEncoder Acadia.Serialize.deleteItemInput input
            , response = Serialize.toBytesDecoder Acadia.Serialize.softDeleteItemResponse
            }
        , onResponse = toMsg
        }


put : (Result Http.Extended.Error () -> msg) -> Backend.UpdateItemInput -> Effect msg
put toMsg input =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Get
            , path = Endpoints.ApiItems
            , request = Serialize.toBytesEncoder Acadia.Serialize.updateItemInput input
            , response = Serialize.toBytesDecoder Acadia.Serialize.updateItemResponse
            }
        , onResponse = toMsg
        }
