module Endpoints exposing
    ( Endpoint
    , EndpointPath(..)
    , fromString
    , toString
    )

import Acadia.Uuid
import Backend
import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Http.Method exposing (Method)


type alias Endpoint responseValue =
    { method : Method
    , path : EndpointPath
    , queryParams : Dict String String
    , request : Bytes.Encode.Encoder
    , response : Bytes.Decode.Decoder responseValue
    }


type EndpointPath
    = ApiAuthLogin
    | ApiAuthSignup
    | ApiAuthLogout
    | ApiAuthSelf
    | ApiOrganizations
    | ApiOrganizationId_Items { organizationID : Backend.OrganizationID }
    | ApiOrganizationId_ItemsItemId { organizationID : Backend.OrganizationID, itemID : Backend.ItemID }


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

        ApiOrganizationId_Items { organizationID } ->
            let
                (Backend.OrganizationID orgID) =
                    organizationID
            in
            "/api/" ++ Acadia.Uuid.toHex orgID ++ "/items"

        ApiOrganizationId_ItemsItemId { organizationID, itemID } ->
            let
                (Backend.OrganizationID orgID) =
                    organizationID

                (Backend.ItemID iID) =
                    itemID
            in
            "/api/" ++ Acadia.Uuid.toHex orgID ++ "/items/" ++ Acadia.Uuid.toHex iID


fromString : String -> Maybe EndpointPath
fromString str =
    case String.split "/" str of
        [ "", "api", "auth", "login" ] ->
            Just ApiAuthLogin

        [ "", "api", "auth", "signup" ] ->
            Just ApiAuthSignup

        [ "", "api", "auth", "logout" ] ->
            Just ApiAuthLogout

        [ "", "api", "auth", "self" ] ->
            Just ApiAuthSelf

        [ "", "api", "organizations" ] ->
            Just ApiOrganizations

        [ "", "api", orgID, "items" ] ->
            Maybe.map
                (\organizationID -> ApiOrganizationId_Items { organizationID = Backend.OrganizationID organizationID })
                (Acadia.Uuid.fromHex orgID)

        [ "", "api", orgID, "items", iID ] ->
            Maybe.map2
                (\organizationID itemID -> ApiOrganizationId_ItemsItemId { organizationID = Backend.OrganizationID organizationID, itemID = Backend.ItemID itemID })
                (Acadia.Uuid.fromHex orgID)
                (Acadia.Uuid.fromHex iID)

        _ ->
            Nothing
