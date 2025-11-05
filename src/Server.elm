port module Server exposing (..)

import Acadia.Api
import Acadia.Transaction
import Backend
import Bytes exposing (Bytes)
import Bytes.Decode
import Bytes.Encode
import Dict exposing (Dict)
import Http
import Platform
import Serialize


main : Program Request Model Msg
main =
    Platform.worker
        { init = init
        , subscriptions = subscriptions
        , update = update
        }


type alias Flags =
    String


type alias Model =
    {}


type alias Headers =
    List ( String, String )


type alias Request =
    { path : String
    , method : String
    , headers : Headers
    , body : String
    }


type alias Response =
    { status : Int
    , headers : Headers
    , body : String
    }


init : Request -> ( Model, Cmd Msg )
init request =
    ( {}
    , if request.method /= "POST" then
        respond { status = 404, body = "Not Found", headers = [] }

      else
        case request.path of
            "/api/auth/self" ->
                acadiaRequest request.headers (AuthSelfResponse Acadia.Api.getUserSelfCodec) Backend.getUserSelf

            "/api/auth/logout" ->
                acadiaRequest request.headers (AuthLogoutResponse Acadia.Api.logoutCodec) Backend.logout

            "/api/auth/login" ->
                case Serialize.decodeFromString Acadia.Api.authInfoCodec request.body of
                    Err _ ->
                        acadiaFailureResponse { status = 400, error = Acadia.Api.Generic "Server error" }

                    Ok authInfo ->
                        if String.length authInfo.email < 3 then
                            acadiaFailureResponse { status = 400, error = Acadia.Api.Field { name = "email", message = "Too short" } }

                        else if String.length authInfo.password < 8 then
                            acadiaFailureResponse { status = 400, error = Acadia.Api.Field { name = "password", message = "Too short" } }

                        else
                            acadiaRequest request.headers (LoginResponse Acadia.Api.loginCodec) (Backend.login authInfo)

            "/api/auth/signup" ->
                case Serialize.decodeFromString Acadia.Api.authInfoCodec request.body of
                    Err _ ->
                        acadiaFailureResponse { status = 400, error = Acadia.Api.Generic "Server error" }

                    Ok authInfo ->
                        if String.length authInfo.email < 3 then
                            acadiaFailureResponse { status = 400, error = Acadia.Api.Field { name = "email", message = "Too short" } }

                        else if String.length authInfo.password < 8 then
                            acadiaFailureResponse { status = 400, error = Acadia.Api.Field { name = "password", message = "Too short" } }

                        else
                            acadiaRequest request.headers (LoginResponse Acadia.Api.loginCodec) (Backend.signup authInfo)

            "/api/organizations/create" ->
                case Serialize.decodeFromString Acadia.Api.createOrganizationCodec request.body of
                    Err _ ->
                        acadiaFailureResponse { status = 400, error = Acadia.Api.Generic "Server error" }

                    Ok newOrg ->
                        if String.length newOrg.name < 1 then
                            acadiaFailureResponse { status = 400, error = Acadia.Api.Field { name = "name", message = "Too short" } }

                        else
                            acadiaRequest request.headers (OrganizationCreateResponse Acadia.Api.organizationCodec) (Backend.createOrganization newOrg)

            _ ->
                acadiaFailureResponse { status = 404, error = Acadia.Api.Generic "Not Found" }
    )


acadiaFailureResponse : { status : Int, error : Acadia.Api.Error } -> Cmd msg
acadiaFailureResponse config =
    respond
        { status = config.status
        , body = Serialize.encodeToString Acadia.Api.errorCodec config.error
        , headers = []
        }


acadiaRequest : Headers -> (Result Http.Error ( Headers, a ) -> msg) -> Acadia.Transaction.Transaction a -> Cmd msg
acadiaRequest headers toMsg (Acadia.Transaction.Transaction enc dec) =
    Http.request
        { url = "http://localhost:9000/_endpoints"
        , method = "POST"
        , headers =
            Http.header "accept" "application/octet-stream"
                :: List.filterMap
                    (\( key, value ) ->
                        case String.toLower key of
                            "cookie" ->
                                Just <| Http.header key value

                            "content-type" ->
                                Just <| Http.header key value

                            _ ->
                                Nothing
                    )
                    headers
        , body = Http.bytesBody "application/octet-stream" (Bytes.Encode.encode enc)
        , expect = Http.expectBytesResponse toMsg (bytesResponseWithHeaders dec)
        , timeout = Nothing
        , tracker = Nothing
        }


bytesResponseWithHeaders : Bytes.Decode.Decoder a -> Http.Response Bytes -> Result Http.Error ( Headers, a )
bytesResponseWithHeaders dec response =
    case response of
        Http.BadUrl_ url ->
            Err <| Http.BadUrl url

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ metadata body ->
            Err <| Http.BadStatus metadata.statusCode

        Http.GoodStatus_ metadata body ->
            case Bytes.Decode.decode dec body of
                Nothing ->
                    Err <| Http.BadBody "Failed to decode"

                Just data ->
                    Ok <| ( Dict.toList metadata.headers, data )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = LoginResponse (Serialize.Codec () ()) (Result Http.Error ( Headers, () ))
    | AuthLogoutResponse (Serialize.Codec () ()) (Result Http.Error ( Headers, () ))
    | AuthSelfResponse (Serialize.Codec () ( Backend.User, Maybe Backend.Organization )) (Result Http.Error ( Headers, ( Backend.User, Maybe Backend.Organization ) ))
    | OrganizationCreateResponse (Serialize.Codec () Backend.Organization) (Result Http.Error ( Headers, Backend.Organization ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginResponse codec result ->
            ( model
            , acadiaResponse codec result
            )

        AuthLogoutResponse codec result ->
            ( model
            , acadiaResponse codec result
            )

        AuthSelfResponse codec result ->
            ( model
            , acadiaResponse codec result
            )

        OrganizationCreateResponse codec result ->
            ( model
            , acadiaResponse codec result
            )


acadiaResponse : Serialize.Codec () a -> Result Http.Error ( Headers, a ) -> Cmd msg
acadiaResponse codec result =
    case result of
        Err _ ->
            respond { status = 400, body = "Database error", headers = [] }

        Ok ( headers, body ) ->
            respond
                { status = 200
                , body = Serialize.encodeToString codec body
                , headers =
                    List.filterMap
                        (\( key, value ) ->
                            case String.toLower key of
                                "content-length" ->
                                    Nothing

                                "set-cookie" ->
                                    Just ( key, setPathOnCookie value )

                                _ ->
                                    Just ( key, value )
                        )
                        headers
                }


port respond : Response -> Cmd msg


setPathOnCookie : String -> String
setPathOnCookie cookie =
    cookie ++ "; Path=/api"
