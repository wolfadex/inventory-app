module Effect exposing
    ( Effect
    , none, batch, map
    , broadcast
    , CustomEffect(..)
    , acadia
    , navigateTo
    )

{-|

@docs Effect
@docs none, batch, map
@docs broadcast

@docs CustomEffect
@docs acadia

@docs navigateTo

-}

import Acadia.Api
import Acadia.Transaction
import Backend.Transaction
import Dict exposing (Dict)
import ElmLand.Effect
import Route
import Route.Path
import Serialize
import Subscription



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


{-| Attempt to run an Acadia transaction
-}
acadia :
    { onResponse : Result Acadia.Api.Error (Result (Serialize.Error ()) value) -> msg
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
    = Acadia
        { transaction : Acadia.Transaction.Transaction msg
        , onFailure : Acadia.Api.Error -> msg
        , path : String
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
        Acadia info ->
            Acadia
                { transaction = Backend.Transaction.map fn info.transaction
                , onFailure = info.onFailure >> fn
                , path = info.path
                }
