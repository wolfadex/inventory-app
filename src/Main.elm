module Main exposing (main)

import Browser.Navigation exposing (Key)
import Bytes.Decode
import Bytes.Encode
import Effect
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
        { onCustomEffect = onCustomEffect
        , onCustomSubscription = onCustomSubscription
        , onUrlChangedEvent = Subscription.UrlChanged
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
        -- Effect.Fetch request ->
        --     ( shared
        --       -- , ElmLand.Http.toCmd request
        --     , request
        --         |> ElmLand.Http.mapError
        --             (\msg ->
        --                 ElmLand.Program.Batch
        --                     [ msg
        --                     , ElmLand.Program.Shared
        --                     ]
        --             )
        --     )
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
onCustomSubscription : Subscription.CustomSubscription Msg -> ElmLand.Subscription.Handler Subscription.Event Msg
onCustomSubscription customSub =
    case customSub of
        Subscription.OnAuthenticationChanged msg ->
            ElmLand.Subscription.handleEvent
                (\event ->
                    case event of
                        Subscription.AuthenticationChanged ->
                            Just msg

                        _ ->
                            Nothing
                )

        Subscription.OnAuthenticationRefreshRequested toMsg ->
            ElmLand.Subscription.handleEvent
                (\event ->
                    case event of
                        Subscription.RefreshAuthentication maybePath ->
                            Just (toMsg maybePath)

                        _ ->
                            Nothing
                )
