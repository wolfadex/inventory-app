port module Server exposing
    ( Headers
    , Model
    , Msg(..)
    , Response
    , main
    )

import Acadia.Serialize
import Acadia.Transaction
import Backend
import Bytes exposing (Bytes)
import Bytes.Decode
import Bytes.Encode
import Dict
import Endpoints
import Http
import Http.Extended
import Http.Method
import Http.Status
import Json.Decode
import Json.Encode
import Platform
import Serialize


main : Program Json.Encode.Value Model Msg
main =
    Platform.worker
        { init = init
        , subscriptions = subscriptions
        , update = update
        }


type alias Model =
    {}


type alias Headers =
    List ( String, String )


type alias Response =
    { status : Int
    , headers : Headers
    , body : String
    }


init : Json.Encode.Value -> ( Model, Cmd Msg )
init requestJson =
    ( {}
    , case Json.Decode.decodeValue Http.Extended.requestDecode requestJson of
        Err _ ->
            respond { status = Http.Status.NotFound, body = "Not Found", headers = [] }

        Ok request ->
            if request.method /= Http.Method.Post then
                respond { status = Http.Status.NotFound, body = "Not Found", headers = [] }

            else
                case Endpoints.fromString request.path of
                    Nothing ->
                        acadiaFailureResponse { status = Http.Status.NotFound, error = Http.Extended.Generic "Not Found" }

                    Just Endpoints.ApiAuthSelf ->
                        acadiaRequest request.headers Acadia.Serialize.getUserSelfResponse Backend.getUserSelf

                    Just Endpoints.ApiAuthLogout ->
                        acadiaRequest request.headers Acadia.Serialize.logoutResponse Backend.logout

                    Just Endpoints.ApiAuthLogin ->
                        withRequestBody
                            (\loginInfo ->
                                acadiaRequest request.headers Acadia.Serialize.loginResponse (Backend.login loginInfo)
                            )
                            request
                            Acadia.Serialize.authInfo

                    Just Endpoints.ApiAuthSignup ->
                        withRequestBody
                            (\signupInfo ->
                                if String.length signupInfo.email < 3 then
                                    acadiaFailureResponse { status = Http.Status.BadRequest, error = Http.Extended.Field { name = "email", message = "Too short" } }

                                else if String.length signupInfo.password < 8 then
                                    acadiaFailureResponse { status = Http.Status.BadRequest, error = Http.Extended.Field { name = "password", message = "Too short" } }

                                else if String.length signupInfo.name < 1 then
                                    acadiaFailureResponse { status = Http.Status.BadRequest, error = Http.Extended.Field { name = "name", message = "Too short" } }

                                else
                                    acadiaRequest request.headers Acadia.Serialize.signupResponse (Backend.signup signupInfo)
                            )
                            request
                            Acadia.Serialize.signUpInfo

                    Just Endpoints.ApiOrganizations ->
                        withRequestBody
                            (\newOrg ->
                                if String.length newOrg.name < 1 then
                                    acadiaFailureResponse { status = Http.Status.BadRequest, error = Http.Extended.Field { name = "name", message = "Too short" } }

                                else
                                    acadiaRequest request.headers Acadia.Serialize.createOrganizationResponse (Backend.createOrganization newOrg)
                            )
                            request
                            Acadia.Serialize.createOrganizationInput

                    Just Endpoints.ApiItemsGet ->
                        withRequestBody
                            (\orgnizationID ->
                                acadiaRequest request.headers
                                    Acadia.Serialize.getItemsResponse
                                    (Backend.getItems orgnizationID)
                            )
                            request
                            Acadia.Serialize.organizationID
    )


withRequestBody : (a -> Cmd msg) -> Http.Extended.Request -> Serialize.Codec a -> Cmd msg
withRequestBody fn request inputCodec =
    case Serialize.decodeFromString inputCodec request.body of
        Nothing ->
            acadiaFailureResponse { status = Http.Status.BadRequest, error = Http.Extended.Generic "Server error" }

        Just input ->
            fn input


acadiaFailureResponse : { status : Http.Status.Status, error : Http.Extended.Error } -> Cmd msg
acadiaFailureResponse config =
    respond
        { status = config.status
        , body = Serialize.encodeToString Http.Extended.errorCodec config.error
        , headers = []
        }


acadiaRequest : Headers -> Serialize.Codec a -> Acadia.Transaction.Transaction a -> Cmd Msg
acadiaRequest headers responseCodec (Acadia.Transaction.Transaction enc dec) =
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
        , expect = Http.expectBytesResponse RespondToClient (bytesResponseWithHeaders (Bytes.Decode.map (Serialize.encodeToString responseCodec) dec))
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

        Http.BadStatus_ metadata _ ->
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
    = RespondToClient (Result Http.Error ( Headers, String ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RespondToClient (Err _) ->
            ( model, respond { status = Http.Status.BadRequest, body = "Database error", headers = [] } )

        RespondToClient (Ok ( headers, body )) ->
            ( model
            , respond
                { status = Http.Status.StatusOk
                , body = body
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
            )


acadiaResponse : Serialize.Codec a -> Result Http.Error ( Headers, a ) -> Cmd msg
acadiaResponse codec result =
    case result of
        Err _ ->
            respond { status = Http.Status.BadRequest, body = "Database error", headers = [] }

        Ok ( headers, body ) ->
            respond
                { status = Http.Status.StatusOk
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


port sendResponse : Json.Encode.Value -> Cmd msg


respond : Http.Extended.Response -> Cmd msg
respond response =
    response
        |> Http.Extended.responseEncode
        |> sendResponse


setPathOnCookie : String -> String
setPathOnCookie cookie =
    cookie ++ "; Path=/api"
