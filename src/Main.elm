module Main exposing (main)

import Browser.Navigation exposing (Key)
import Bytes.Decode
import Bytes.Encode
import Effect
import ElmLand.Effect
import ElmLand.Program exposing (Msg, Program)
import ElmLand.Subscription
import Endpoints
import Http
import Http.Extended
import Http.Method
import Serialize
import Shared
import Subscription
import Url exposing (Url)


{-| Start the Elm Land application
-}
main : Program
main =
    ElmLand.Program.new
        { toCmd = ElmLand.Effect.toCmd onCustomEffect
        , toSub = ElmLand.Subscription.toSub onCustomSub
        }


{-| How should an Effect become a Platform.Cmd?
-}
onCustomEffect :
    Effect.CustomEffect Msg
    -> Url
    -> Key
    -> Shared.Model
    -> ( Shared.Model, Cmd Msg )
onCustomEffect customEffect _ _ shared =
    case customEffect of
        Effect.EndpointRequest info ->
            ( shared
            , Http.request
                { method = Http.Method.toString info.endpoint.method
                , url = Endpoints.toString info.endpoint.path
                , body = Http.bytesBody "application/octet-stream" (Bytes.Encode.encode info.endpoint.request)
                , expect =
                    Http.expectBytesResponse
                        (\result ->
                            case result of
                                Err err ->
                                    info.onFailure err

                                Ok msg ->
                                    msg
                        )
                        (\response ->
                            case response of
                                Http.BadUrl_ _ ->
                                    Err <| Http.Extended.Generic "Invalid URL"

                                Http.Timeout_ ->
                                    Err <| Http.Extended.Generic "Timeout"

                                Http.NetworkError_ ->
                                    Err <| Http.Extended.Generic "Network error"

                                Http.BadStatus_ _ body ->
                                    case Serialize.decodeFromBytes Http.Extended.errorCodec body of
                                        Just error ->
                                            Err error

                                        Nothing ->
                                            Err <| Http.Extended.Generic "Error"

                                Http.GoodStatus_ _ body ->
                                    case Bytes.Decode.decode info.endpoint.response body of
                                        Just a ->
                                            Ok a

                                        Nothing ->
                                            Err <| Http.Extended.Generic "Failed to read response"
                        )
                , headers = []
                , timeout = Nothing
                , tracker = Nothing
                }
            )


{-| How should a Subscription become a Platform.Sub?
-}
onCustomSub : Subscription.CustomSubscription Msg -> Sub Msg
onCustomSub customSub =
    case customSub of
        Subscription.OnAuthenticationChanged _ ->
            Sub.none

        Subscription.OnAuthenticationRefreshRequested _ ->
            Sub.none
