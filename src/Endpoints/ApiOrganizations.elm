module Endpoints.ApiOrganizations exposing (post)

import Acadia.Serialize
import Backend
import Dict
import Effect exposing (Effect)
import Endpoints
import Http.Extended
import Http.Method
import Serialize


post : (Result Http.Extended.Error Backend.Organization -> msg) -> { name : String } -> Effect msg
post toMsg newOrgInfo =
    Effect.endpoint
        { endpoint =
            { method = Http.Method.Post
            , path = Endpoints.ApiOrganizations
            , queryParams = Dict.empty
            , request = Serialize.toBytesEncoder Acadia.Serialize.createOrganizationInput newOrgInfo
            , response = Serialize.toBytesDecoder Acadia.Serialize.organization
            }
        , onResponse = toMsg
        }
