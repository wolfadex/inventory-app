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
        case Debug.log "path" request.path of
            "/api/auth/self" ->
                acadiaRequest request.headers (AuthSelfResponse Acadia.Api.getUserSelfCodec) Backend.getUserSelf

            "/api/auth/authenticate" ->
                case Serialize.decodeFromString Acadia.Api.authInfoCodec request.body of
                    Err _ ->
                        respond { status = 400, body = "Decode error", headers = [] }

                    Ok authInfo ->
                        if String.length authInfo.email < 3 then
                            respond { status = 400, body = "Invalid email", headers = [] }

                        else if String.length authInfo.password < 8 then
                            respond { status = 400, body = "Password too short", headers = [] }

                        else
                            acadiaRequest request.headers (AuthenticateResponse Acadia.Api.authenticateCodec) (Backend.authenticate authInfo)

            "/api/auth/signup" ->
                case Serialize.decodeFromString Acadia.Api.authInfoCodec request.body of
                    Err _ ->
                        respond { status = 400, body = "Decode error", headers = [] }

                    Ok authInfo ->
                        if String.length authInfo.email < 3 then
                            respond { status = 400, body = "Invalid email", headers = [] }

                        else if String.length authInfo.password < 8 then
                            respond { status = 400, body = "Password too short", headers = [] }

                        else
                            acadiaRequest request.headers (AuthenticateResponse Acadia.Api.authenticateCodec) (Backend.signup authInfo)

            "/api/organizations/create" ->
                case Serialize.decodeFromString Acadia.Api.createOrganizationCodec request.body |> Debug.log "org create args" of
                    Err _ ->
                        respond { status = 400, body = "Decode error", headers = [] }

                    Ok newOrg ->
                        if String.length newOrg.name < 1 then
                            respond { status = 400, body = "Invalid name", headers = [] }

                        else
                            acadiaRequest request.headers (OrganizationCreateResponse Acadia.Api.organizationCodec) (Backend.createOrganization newOrg)

            _ ->
                respond { status = 404, body = "Not Found", headers = [] }
    )


acadiaRequest : Headers -> (Result Http.Error ( Headers, a ) -> msg) -> Acadia.Transaction.Transaction a -> Cmd msg
acadiaRequest headers toMsg (Acadia.Transaction.Transaction enc dec) =
    Http.request
        { url = "http://localhost:9000/_endpoints"
        , method = "POST"
        , headers =
            List.filterMap
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
    = AuthenticateResponse (Serialize.Codec () ()) (Result Http.Error ( Headers, () ))
    | AuthSelfResponse (Serialize.Codec () ( Backend.User, Maybe Backend.Organization )) (Result Http.Error ( Headers, ( Backend.User, Maybe Backend.Organization ) ))
    | OrganizationCreateResponse (Serialize.Codec () Backend.Organization) (Result Http.Error ( Headers, Backend.Organization ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AuthenticateResponse codec result ->
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
    case Debug.log "res" result of
        Err _ ->
            respond { status = 400, body = "Database error", headers = [] }

        Ok ( headers, body ) ->
            respond
                { status = 200
                , body = Serialize.encodeToString codec body
                , headers =
                    List.filter
                        (\( key, _ ) ->
                            case String.toLower key of
                                "content-length" ->
                                    False

                                _ ->
                                    True
                        )
                        headers
                }


port respond : Response -> Cmd msg
