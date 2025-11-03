module Main exposing (main)

import Acadia.Api
import Acadia.Transaction
import Browser.Navigation exposing (Key)
import Bytes.Encode
import Effect exposing (Effect)
import ElmLand.Effect
import ElmLand.Program exposing (Msg, Program)
import ElmLand.Subscription
import Http
import Interop
import Json.Decode as Json
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
onCustomEffect customEffect url key shared =
    case customEffect of
        Effect.ReportUnexpectedFlags error ->
            ( shared
            , Interop.reportUnexpectedFlags
                { error = Json.errorToString error
                }
            )

        Effect.Command cmd ->
            ( shared, cmd )

        Effect.Acadia info ->
            let
                (Acadia.Transaction.Transaction encoder decoder) =
                    info.transaction
            in
            ( shared
            , Http.request
                { url = "/api" ++ info.path
                , method = "POST"
                , headers = []
                , body = Http.bytesBody "application/octet-stream" (Serialize.encodeSimple encoder)
                , expect =
                    Http.expectBytes
                        (\result ->
                            case result of
                                Err err ->
                                    info.onFailure err

                                Ok msg ->
                                    msg
                        )
                        decoder
                , timeout = Nothing
                , tracker = Nothing
                }
            )


{-| How should a Subscription become a Platform.Sub?
-}
onCustomSub : Subscription.CustomSubscription Msg -> Sub Msg
onCustomSub customSub =
    case customSub of
        Subscription.OnUrlChanged _ ->
            Sub.none

        Subscription.OnDocumentPointerDown toMsg ->
            Interop.onDocumentPointerDown toMsg

        Subscription.OnAuthenticationChanged _ ->
            Sub.none

        Subscription.OnAuthenticationRefreshRequested _ ->
            Sub.none
