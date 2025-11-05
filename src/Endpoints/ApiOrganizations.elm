module Endpoints.ApiOrganizations exposing (post)

import Acadia.Api
import Backend
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
            , request = Serialize.toBytesEncoder Acadia.Api.createOrganizationCodec newOrgInfo
            , response = Serialize.toBytesDecoder Acadia.Api.organizationCodec
            }
        , onResponse = toMsg
        }
