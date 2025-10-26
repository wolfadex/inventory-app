module Effect exposing
    ( Effect
    , none, batch, map
    , broadcast
    , CustomEffect(..)
    , reportUnexpectedFlags, acadia
    , navigateTo
    )

{-|

@docs Effect
@docs none, batch, map
@docs broadcast

@docs CustomEffect
@docs reportUnexpectedFlags, acadia

@docs navigateTo

-}

import Acadia.Transaction exposing (Transaction)
import Backend.Transaction
import ElmLand.Effect
import Json.Decode as Json
import Subscription exposing (Subscription)
import Route.Path



-- EFFECTS


{-| Represents a side-effect you want to run
-}
type alias Effect msg =
    ElmLand.Effect.Effect
        (CustomEffect msg)
        msg


{-| Do nothing (Similar to Cmd.none)
-}
none : Effect msg
none =
    ElmLand.Effect.none


{-| Perform multiple effects at once (Similar to Cmd.batch)
-}
batch : List (Effect msg) -> Effect msg
batch =
    ElmLand.Effect.batch


{-| Notify any custom subscriptions that an event has occurred
-}
broadcast : Subscription.Event -> Effect msg
broadcast event =
    ElmLand.Effect.broadcast event


{-| Report a problem with the initial JSON sent into your app
-}
reportUnexpectedFlags : Json.Error -> Effect msg
reportUnexpectedFlags error =
    ElmLand.Effect.custom (ReportUnexpectedFlags error)


{-| Attempt to run an Acadia transaction
-}
acadia :
    { onResponse : Maybe value -> msg
    , transaction : Transaction value
    }
    -> Effect msg
acadia props =
    -- Strips the "value" type variable
    -- so things work nicely with "Effect msg"
    ElmLand.Effect.custom
        (Acadia
            { transaction =
                Backend.Transaction.map
                    (Just >> props.onResponse)
                    props.transaction
            , onFailure = props.onResponse Nothing
            }
        )

-- Internal Navigation

navigateTo : Route.Path.Path -> Effect msg
navigateTo path =
    ElmLand.Effect.pushUrl
        (Route.Path.toString path)



-- CUSTOM EFFECTS


{-| Any custom effects specific to this application
-}
type CustomEffect msg
    = ReportUnexpectedFlags Json.Error
    | Acadia
        { transaction : Transaction msg
        , onFailure : msg
        }



-- MAP


{-| Convert an Effect from one message type to another
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    ElmLand.Effect.map (mapCustomEffect fn) fn effect


{-| Convert a CustomEffect from one message type to another
-}
mapCustomEffect : (msg1 -> msg2) -> CustomEffect msg1 -> CustomEffect msg2
mapCustomEffect fn customEffect =
    case customEffect of
        ReportUnexpectedFlags data ->
            ReportUnexpectedFlags data

        Acadia info ->
            Acadia
                { transaction = Backend.Transaction.map fn info.transaction
                , onFailure = fn info.onFailure
                }
