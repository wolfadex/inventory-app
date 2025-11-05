module Endpoints exposing
    ( Endpoint
    , EndpointPath(..)
    , fromString
    , toString
    )

import Bytes.Decode
import Bytes.Encode
import Http.Method exposing (Method)



-- type Method
--     = Get
--     | Post
--     | Put
--     | Patch
--     | Delete
-- type alias Request a b =
--     { method : Method
--     , payload : a
--     , response : b
--     }
-- type alias Route params =
--     { params : params
--     , path : Route.Path.Path
--     , query : Dict String String
--     , fragment : Maybe String
--     , url : Url
--     }


type alias Endpoint responseValue =
    { method : Method
    , path : EndpointPath
    , request : Bytes.Encode.Encoder
    , response : Bytes.Decode.Decoder responseValue
    }


type EndpointPath
    = ApiAuthLogin
    | ApiAuthSignup
    | ApiAuthLogout
    | ApiAuthSelf
    | ApiOrganizations


toString : EndpointPath -> String
toString endpoint =
    case endpoint of
        ApiAuthLogin ->
            "/api/auth/login"

        ApiAuthSignup ->
            "/api/auth/signup"

        ApiAuthLogout ->
            "/api/auth/logout"

        ApiAuthSelf ->
            "/api/auth/self"

        ApiOrganizations ->
            "/api/organizations"


fromString : String -> Maybe EndpointPath
fromString str =
    case str of
        "/api/auth/login" ->
            Just ApiAuthLogin

        "/api/auth/signup" ->
            Just ApiAuthSignup

        "/api/auth/logout" ->
            Just ApiAuthLogout

        "/api/auth/self" ->
            Just ApiAuthSelf

        "/api/organizations" ->
            Just ApiOrganizations

        _ ->
            Nothing
