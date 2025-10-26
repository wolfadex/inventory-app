module Subscription exposing
    ( Subscription
    , none, batch
    , onResize, onUrlChange
    , map
    , Event(..), onEvent
    , CustomSubscription(..)
    , onAuthenticationChange
    )

{-|

@docs Subscription
@docs none, batch
@docs onResize, onUrlChange
@docs map

@docs Event, onEvent
@docs CustomSubscription

@docs onAuthenticationChange

-}

import ElmLand.Subscription
import Json.Decode as Json


{-| Describes a listener for specific events
(an extension of Elm's `Sub msg` type)
-}
type alias Subscription msg =
    ElmLand.Subscription.Subscription
        (CustomSubscription msg)
        msg



-- ELM/CORE


{-| Don't listen for any events (Similar to `Sub.none`)
-}
none : Subscription msg
none =
    ElmLand.Subscription.none


{-| Listen for multiple events (Similar to `Sub.batch`)
-}
batch : List (Subscription msg) -> Subscription msg
batch list =
    ElmLand.Subscription.batch list


{-| Runs whenever the window is resized (Similar to `Browser.Events.onResize`)
-}
onResize : (Int -> Int -> msg) -> Subscription msg
onResize toMsg =
    ElmLand.Subscription.onResize toMsg


{-| Runs whenever the URL changes but a new page is not loaded
-}
onUrlChange : msg -> Subscription msg
onUrlChange msg =
    ElmLand.Subscription.custom (OnUrlChanged msg)


{-| Listen for document.pointerdown events
-}
onDocumentPointerDown : (Json.Value -> msg) -> Subscription msg
onDocumentPointerDown toMsg =
    ElmLand.Subscription.custom (OnDocumentPointerDown toMsg)



-- CUSTOM SUBSCRIPTIONS



{-| Runs whenever the URL changes but a new page is not loaded
-}
onAuthenticationChange : msg -> Subscription msg
onAuthenticationChange msg =
    ElmLand.Subscription.custom (OnAuthenticationChanged msg)


{-| Events that can be sent with `Effect.broadcast`
-}
type Event
    = UrlChanged
    | AuthenticationChanged


{-| Describes a custom subscription outside of the
standard ones provided by the `ElmLand.Subscription` module
-}
type CustomSubscription msg
    = OnUrlChanged msg
    | OnDocumentPointerDown (Json.Value -> msg)
    | OnAuthenticationChanged msg



-- MAP


map : (msg1 -> msg2) -> Subscription msg1 -> Subscription msg2
map fn sub =
    ElmLand.Subscription.map (mapCustom fn) fn sub


mapCustom :
    (msg1 -> msg2)
    -> CustomSubscription msg1
    -> CustomSubscription msg2
mapCustom fn sub =
    case sub of
        OnUrlChanged msg1 ->
            OnUrlChanged (fn msg1)

        OnDocumentPointerDown toMsg1 ->
            OnDocumentPointerDown (fn << toMsg1)

        OnAuthenticationChanged msg1 ->
            OnAuthenticationChanged (fn msg1)



-- NEEDED BY ELM LAND


onEvent : Event -> Subscription msg -> List msg
onEvent event sub =
    ElmLand.Subscription.onEvent sub <|
        \customSub ->
            case ( event, customSub ) of
                ( UrlChanged, OnUrlChanged fn ) ->
                    [ fn ]

                ( UrlChanged, _ ) ->
                    []

                ( AuthenticationChanged, OnAuthenticationChanged fn ) ->
                    [ fn ]

                ( AuthenticationChanged, _ ) ->
                    []
