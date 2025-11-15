module Effect exposing
    ( Effect
    , none, batch, map
    , broadcast
    , CustomEffect(..)
    , routeTo, pushUrl
    , endpoint
    -- , get
    )

{-|

@docs Effect
@docs none, batch, map
@docs broadcast

@docs CustomEffect

@docs routeTo, pushUrl
@docs endpoint

-}

import Bytes.Decode
import Dict exposing (Dict)
import ElmLand.Effect
import ElmLand.Http
import Endpoints
import Http
import Http.Extended
import Json.Decode
import Route
import Route.Path
import Subscription



-- EFFECTS


{-| Represents a side-effect you want to run
-}
type alias Effect msg =
    ElmLand.Effect.Effect
        Subscription.Event
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


endpoint :
    { onResponse : Result Http.Extended.Error value -> msg
    , endpoint : Endpoints.Endpoint value
    }
    -> Effect msg
endpoint props =
    -- Strips the "value" type variable
    -- so things work nicely with "Effect msg"
    ElmLand.Effect.custom
        (EndpointRequest
            { endpoint =
                { method = props.endpoint.method
                , path = props.endpoint.path
                , queryParams = props.endpoint.queryParams
                , request = props.endpoint.request
                , response =
                    Bytes.Decode.map
                        (Ok >> props.onResponse)
                        props.endpoint.response
                }
            , onFailure = Err >> props.onResponse
            }
        )



-- Internal Navigation


routeTo : { path : Route.Path.Path, query : Dict String String } -> Effect msg
routeTo { path, query } =
    ElmLand.Effect.pushUrl
        (Route.toString { path = path, query = query, fragment = Nothing })


pushUrl : String -> Effect msg
pushUrl =
    ElmLand.Effect.pushUrl



-- get : { url : String, decoder : Json.Decode.Decoder value, onResponse : Result Http.Error value -> msg } -> Effect msg
-- get props =
--     ElmLand.Effect.custom
--         (Fetch
--             (ElmLand.Http.get props)
--         )
-- CUSTOM EFFECTS


{-| Any custom effects specific to this application
-}
type CustomEffect msg
    = EndpointRequest
        { endpoint : Endpoints.Endpoint msg
        , onFailure : Http.Extended.Error -> msg
        }



-- | Fetch (ElmLand.Http.Request msg)
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
        EndpointRequest info ->
            EndpointRequest
                { endpoint =
                    { method = info.endpoint.method
                    , path = info.endpoint.path
                    , queryParams = info.endpoint.queryParams
                    , request = info.endpoint.request
                    , response = Bytes.Decode.map fn info.endpoint.response
                    }
                , onFailure = info.onFailure >> fn
                }



-- Fetch info ->
--     Fetch (ElmLand.Http.map fn info)
