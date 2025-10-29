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


{-| Attempt to run an Acadia transaction
-}
acadia :
    { onResponse : Result (Serialize.Error Http.Error) value -> msg
    , responseDecoder : Bytes.Decode.Decoder (Result (Serialize.Error Http.Error) value)
    , requestBody : Bytes
    , path : String
    }
    -> Effect msg
acadia props =
    -- Strips the "value" type variable
    -- so things work nicely with "Effect msg"
    ElmLand.Effect.custom
        (Acadia
            { responseDecoder = Bytes.Decode.map props.onResponse props.responseDecoder
            , path = props.path
            , requestBody = props.requestBody
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
        { responseDecoder : Bytes.Decode.Decoder msg
        , path : String
        , requestBody : Bytes
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
                { responseDecoder = Bytes.Decode.map fn info.responseDecoder
                , path = info.path
                , requestBody = info.requestBody
                }
