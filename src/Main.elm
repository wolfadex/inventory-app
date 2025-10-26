module Main exposing (main)

import Acadia.Transaction
import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import ElmLand.Effect
import ElmLand.Program exposing (Msg, Program)
import ElmLand.Subscription
import Interop
import Json.Decode as Json
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

        Effect.Acadia info ->
            ( shared
            , Acadia.Transaction.attempt "/_endpoints"
                (Maybe.withDefault info.onFailure)
                info.transaction
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
