module Effect exposing
    ( Effect
    , none, batch, map
    , broadcast
    , CustomEffect(..)
    , reportUnexpectedFlags, acadia
    , navigateTo
    , command
    )

{-|

@docs Effect
@docs none, batch, map
@docs broadcast

@docs CustomEffect
@docs reportUnexpectedFlags, acadia

@docs navigateTo

-}

import Acadia.Transaction
import Backend.Transaction
import Bytes exposing (Bytes)
import Bytes.Decode
import Dict exposing (Dict)
import ElmLand.Effect
import Http
import Json.Decode as Json
import Route
import Route.Path
import Serialize
import Subscription exposing (Subscription)



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


command : Cmd msg -> Effect msg
command cmd =
    ElmLand.Effect.custom (Command cmd)


{-| Attempt to run an Acadia transaction
-}
acadia :
    { onResponse : Result Http.Error (Result (Serialize.Error ()) value) -> msg
    , transaction : Acadia.Transaction.Transaction (Result (Serialize.Error ()) value)
    , path : String
    }
    -> Effect msg
acadia props =
    -- Strips the "value" type variable
    -- so things work nicely with "Effect msg"
    ElmLand.Effect.custom
        (Acadia
            { transaction =
                Backend.Transaction.map
                    (Ok >> props.onResponse)
                    props.transaction
            , onFailure = Err >> props.onResponse
            , path = props.path
            }
        )



-- Internal Navigation


navigateTo : { path : Route.Path.Path, query : Dict String String } -> Effect msg
navigateTo { path, query } =
    ElmLand.Effect.pushUrl
        (Route.toString { path = path, query = query, fragment = Nothing })



-- CUSTOM EFFECTS


{-| Any custom effects specific to this application
-}
type CustomEffect msg
    = ReportUnexpectedFlags Json.Error
    | Acadia
        { transaction : Acadia.Transaction.Transaction msg
        , onFailure : Http.Error -> msg
        , path : String
        }
    | Command (Cmd msg)



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
                , onFailure = info.onFailure >> fn
                , path = info.path
                }

        Command m1 ->
            Command (Cmd.map fn m1)
