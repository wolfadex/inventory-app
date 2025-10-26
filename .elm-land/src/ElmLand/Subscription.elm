-- 📦 Standard module for https://elm.land 🌈 --


module ElmLand.Subscription exposing
    ( Subscription
    , none, batch
    , map
    , onAnimationFrame, onAnimationFrameDelta
    , onClick, onKeyDown, onKeyPress, onKeyUp
    , onMouseDown, onMouseMove, onMouseUp
    , onResize, onVisibilityChange
    , custom
    , onEvent, toSub
    )

{-| A helper module for defining your own `Subscription` module. Comes
with functions for all the `Sub msg` functions defined in `elm/*` packages.

This module is completely optional, and recommended by default.

@docs Subscription


### elm/core

@docs none, batch
@docs map


### elm/browser

@docs onAnimationFrame, onAnimationFrameDelta
@docs onClick, onKeyDown, onKeyPress, onKeyUp
@docs onMouseDown, onMouseMove, onMouseUp
@docs onResize, onVisibilityChange


### Custom subscriptions

@docs custom
@docs onEvent, toSub

-}

import Browser.Events
import Json.Decode as Json
import Time


{-| Represents a subscription for an event from the browser or somewhere else in
the application.
-}
type Subscription custom msg
    = -- elm/core
      None
    | Batch (List (Subscription custom msg))
      -- elm/browser
    | OnAnimationFrame (Time.Posix -> msg)
    | OnAnimationFrameDelta (Float -> msg)
    | OnKeyDown (Json.Decoder msg)
    | OnKeyPress (Json.Decoder msg)
    | OnKeyUp (Json.Decoder msg)
    | OnClick (Json.Decoder msg)
    | OnMouseDown (Json.Decoder msg)
    | OnMouseMove (Json.Decoder msg)
    | OnMouseUp (Json.Decoder msg)
    | OnVisibilityChange (Browser.Events.Visibility -> msg)
    | OnResize (Int -> Int -> msg)
      -- CUSTOM
    | Custom custom


{-| Don't subscribe to any events.
-}
none : Subscription c msg
none =
    None


{-| Subscribe to multiple events at once
-}
batch : List (Subscription c msg) -> Subscription c msg
batch =
    Batch


{-| See `Browser.Events.onResize`
-}
onResize : (Int -> Int -> msg) -> Subscription c msg
onResize =
    OnResize


{-| See `Browser.Events.onAnimationFrame`
-}
onAnimationFrame : (Time.Posix -> msg) -> Subscription c msg
onAnimationFrame =
    OnAnimationFrame


{-| See `Browser.Events.onAnimationFrameDelta`
-}
onAnimationFrameDelta : (Float -> msg) -> Subscription c msg
onAnimationFrameDelta =
    OnAnimationFrameDelta


{-| See `Browser.Events.onKeyDown`
-}
onKeyDown : Json.Decoder msg -> Subscription c msg
onKeyDown =
    OnKeyDown


{-| See `Browser.Events.onKeyPress`
-}
onKeyPress : Json.Decoder msg -> Subscription c msg
onKeyPress =
    OnKeyPress


{-| See `Browser.Events.onKeyUp`
-}
onKeyUp : Json.Decoder msg -> Subscription c msg
onKeyUp =
    OnKeyUp


{-| See `Browser.Events.onClick`
-}
onClick : Json.Decoder msg -> Subscription c msg
onClick =
    OnClick


{-| See `Browser.Events.onMouseDown`
-}
onMouseDown : Json.Decoder msg -> Subscription c msg
onMouseDown =
    OnMouseDown


{-| See `Browser.Events.onMouseMove`
-}
onMouseMove : Json.Decoder msg -> Subscription c msg
onMouseMove =
    OnMouseMove


{-| See `Browser.Events.onMouseUp`
-}
onMouseUp : Json.Decoder msg -> Subscription c msg
onMouseUp =
    OnMouseUp


{-| See `Browser.Events.onVisibilityChange`
-}
onVisibilityChange : (Browser.Events.Visibility -> msg) -> Subscription c msg
onVisibilityChange =
    OnVisibilityChange


{-| Define a custom subscription that can be triggered
using `Effect.broadcast`
-}
custom : custom -> Subscription custom msg
custom =
    Custom


{-| Convert a Subscription to use a different kind of message.
-}
map :
    (custom1 -> custom2)
    -> (msg1 -> msg2)
    -> Subscription custom1 msg1
    -> Subscription custom2 msg2
map fnCustom fnMsg sub =
    case sub of
        None ->
            None

        Batch list ->
            Batch (List.map (map fnCustom fnMsg) list)

        OnResize handler ->
            OnResize (\w h -> fnMsg (handler w h))

        OnAnimationFrame handler ->
            OnAnimationFrame (handler >> fnMsg)

        OnAnimationFrameDelta handler ->
            OnAnimationFrameDelta (handler >> fnMsg)

        OnKeyDown decoder ->
            OnKeyDown (Json.map fnMsg decoder)

        OnKeyPress decoder ->
            OnKeyPress (Json.map fnMsg decoder)

        OnKeyUp decoder ->
            OnKeyUp (Json.map fnMsg decoder)

        OnClick decoder ->
            OnClick (Json.map fnMsg decoder)

        OnMouseDown decoder ->
            OnMouseDown (Json.map fnMsg decoder)

        OnMouseMove decoder ->
            OnMouseMove (Json.map fnMsg decoder)

        OnMouseUp decoder ->
            OnMouseUp (Json.map fnMsg decoder)

        OnVisibilityChange handler ->
            OnVisibilityChange (handler >> fnMsg)

        Custom c ->
            Custom (fnCustom c)


onEvent : Subscription custom msg -> (custom -> List msg) -> List msg
onEvent sub toMsgs =
    case sub of
        Batch children ->
            List.concatMap (\s -> onEvent s toMsgs) children

        Custom c ->
            toMsgs c

        _ ->
            []


toSub : (c -> Sub msg) -> Subscription c msg -> Sub msg
toSub onCustomSub sub =
    case sub of
        None ->
            Sub.none

        Batch children ->
            Sub.batch (List.map (toSub onCustomSub) children)

        OnResize handler ->
            Browser.Events.onResize handler

        OnAnimationFrame handler ->
            Browser.Events.onAnimationFrame handler

        OnAnimationFrameDelta handler ->
            Browser.Events.onAnimationFrameDelta handler

        OnKeyDown handler ->
            Browser.Events.onKeyDown handler

        OnKeyPress handler ->
            Browser.Events.onKeyPress handler

        OnKeyUp handler ->
            Browser.Events.onKeyUp handler

        OnClick handler ->
            Browser.Events.onClick handler

        OnMouseDown handler ->
            Browser.Events.onMouseDown handler

        OnMouseMove handler ->
            Browser.Events.onMouseMove handler

        OnMouseUp handler ->
            Browser.Events.onMouseUp handler

        OnVisibilityChange handler ->
            Browser.Events.onVisibilityChange handler

        Custom c ->
            onCustomSub c
