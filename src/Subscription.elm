module Subscription exposing
    ( Subscription
    , none, batch
    , map
    , Event(..)
    , CustomSubscription(..)
    , onAuthenticationChange, onAuthenticationRefreshRequested
    )

{-|

@docs Subscription
@docs none, batch
@docs map

@docs Event
@docs CustomSubscription

@docs onAuthenticationChange, onAuthenticationRefreshRequested

-}

import ElmLand.Subscription
import Route.Path
import Url exposing (Url)


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



-- CUSTOM SUBSCRIPTIONS


onAuthenticationChange : msg -> Subscription msg
onAuthenticationChange msg =
    ElmLand.Subscription.custom (OnAuthenticationChanged msg)


onAuthenticationRefreshRequested : (Maybe String -> msg) -> Subscription msg
onAuthenticationRefreshRequested toMsg =
    ElmLand.Subscription.custom (OnAuthenticationRefreshRequested toMsg)


{-| Events that can be sent with `Effect.broadcast`
-}
type Event
    = AuthenticationChanged
    | RefreshAuthentication (Maybe String)
    | UrlChanged Url


{-| Describes a custom subscription outside of the
standard ones provided by the `ElmLand.Subscription` module
-}
type CustomSubscription msg
    = OnAuthenticationChanged msg
    | OnAuthenticationRefreshRequested (Maybe String -> msg)



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
        OnAuthenticationChanged msg1 ->
            OnAuthenticationChanged (fn msg1)

        OnAuthenticationRefreshRequested toMsg1 ->
            OnAuthenticationRefreshRequested (fn << toMsg1)
