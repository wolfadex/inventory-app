module Main exposing (main)

import Acadia.Api
import Acadia.Transaction
import Browser.Navigation exposing (Key)
import Bytes.Decode
import Effect
import ElmLand.Effect
import ElmLand.Program exposing (Msg, Program)
import ElmLand.Subscription
import Http
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
        Effect.Acadia info ->
            let
                (Acadia.Transaction.Transaction encoder decoder) =
                    info.transaction
            in
            ( shared
            , Http.post
                { url = "/api" ++ info.path
                , body = Http.bytesBody "application/octet-stream" (Serialize.encodeSimple encoder)
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
                                    Err <| Acadia.Api.Generic "Invalid URL"

                                Http.Timeout_ ->
                                    Err <| Acadia.Api.Generic "Timeout"

                                Http.NetworkError_ ->
                                    Err <| Acadia.Api.Generic "Network error"

                                Http.BadStatus_ _ body ->
                                    case Serialize.decodeFromBytes Acadia.Api.errorCodec body of
                                        Ok error ->
                                            Err error

                                        Err _ ->
                                            Err <| Acadia.Api.Generic "Error"

                                Http.GoodStatus_ _ body ->
                                    case Bytes.Decode.decode decoder body of
                                        Just a ->
                                            Ok a

                                        Nothing ->
                                            Err <| Acadia.Api.Generic "Failed to read response"
                        )
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
