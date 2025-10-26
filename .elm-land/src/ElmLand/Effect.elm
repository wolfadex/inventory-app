-- 📦 Standard module for https://elm.land 🌈 --


module ElmLand.Effect exposing
    ( Effect
    , none, batch, map
    , custom, broadcast
    , sendMsg, sendMsgAfterDelay
    , request
    , pushUrl, replaceUrl, back, forward, load, reload, reloadAndSkipCache
    , focus, blur, getViewport, getViewportOf, setViewport, setViewportOf, getElement
    , toCmd
    )

{-| A helper module for defining your own `Effect` module. Comes
with functions for all the `Cmd msg` functions defined in `elm/*` packages.

This module is completely optional, and recommended by default.

@docs Effect
@docs none, batch, map
@docs custom, broadcast
@docs sendMsg, sendMsgAfterDelay
@docs request
@docs pushUrl, replaceUrl, back, forward, load, reload, reloadAndSkipCache
@docs focus, blur, getViewport, getViewportOf, setViewport, setViewportOf, getElement


### Used internally by Elm Land to convert Effects into messages

@docs toCmd

-}

import Browser.Dom
import Browser.Navigation
import ElmLand.Http
import Process
import Subscription exposing (Event, Subscription)
import Task
import Url exposing (Url)


type Effect custom msg
    = -- Core
      -- https://package.elm-lang.org/packages/elm/core/latest/Platform-Cmd
      None
    | Batch (List (Effect custom msg))
      -- Http
      -- https://package.elm-lang.org/packages/elm/http/latest/Http
    | Http (ElmLand.Http.Request msg)
      -- Browser.Navigation
      -- https://package.elm-lang.org/packages/elm/browser/latest/Browser-Navigation
    | PushUrl String
    | ReplaceUrl String
    | Back Int
    | Forward Int
    | Load String
    | Reload
    | ReloadAndSkipCache
      -- Browser.Dom
      -- https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom
    | Focus String (Result () () -> msg)
    | Blur String (Result () () -> msg)
    | GetViewport (Result () Browser.Dom.Viewport -> msg)
    | GetViewportOf String (Result () Browser.Dom.Viewport -> msg)
    | SetViewport Float Float msg
    | SetViewportOf String Float Float (Result () () -> msg)
    | GetElement String (Result () Browser.Dom.Element -> msg)
      -- Elm Land helpers
    | SendMsg msg
    | SendMsgAfterDelay Float msg
      -- User-defined
    | Broadcast Event
    | Custom custom


none : Effect c msg
none =
    None


batch : List (Effect c msg) -> Effect c msg
batch =
    Batch


sendMsg : msg -> Effect c msg
sendMsg =
    SendMsg


sendMsgAfterDelay : Float -> msg -> Effect c msg
sendMsgAfterDelay =
    SendMsgAfterDelay


custom : custom -> Effect custom msg
custom =
    Custom


broadcast : Event -> Effect c msg
broadcast =
    Broadcast


request : ElmLand.Http.Request msg -> Effect c msg
request =
    Http


pushUrl : String -> Effect c msg
pushUrl =
    PushUrl


replaceUrl : String -> Effect c msg
replaceUrl =
    ReplaceUrl


back : Int -> Effect c msg
back =
    Back


forward : Int -> Effect c msg
forward =
    Forward


load : String -> Effect c msg
load =
    Load


reload : Effect c msg
reload =
    Reload


reloadAndSkipCache : Effect c msg
reloadAndSkipCache =
    ReloadAndSkipCache


blur : String -> (Result () () -> msg) -> Effect c msg
blur =
    Blur


focus : String -> (Result () () -> msg) -> Effect c msg
focus =
    Focus


getViewport : (Result () Browser.Dom.Viewport -> msg) -> Effect c msg
getViewport =
    GetViewport


getViewportOf : String -> (Result () Browser.Dom.Viewport -> msg) -> Effect c msg
getViewportOf =
    GetViewportOf


setViewport : Float -> Float -> msg -> Effect c msg
setViewport =
    SetViewport


setViewportOf : String -> Float -> Float -> (Result () () -> msg) -> Effect c msg
setViewportOf =
    SetViewportOf


getElement : String -> (Result () Browser.Dom.Element -> msg) -> Effect c msg
getElement =
    GetElement


map : (custom1 -> custom2) -> (msg1 -> msg2) -> Effect custom1 msg1 -> Effect custom2 msg2
map fnCustom fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fnCustom fn) list)

        SendMsg msg ->
            SendMsg (fn msg)

        SendMsgAfterDelay delay msg ->
            SendMsgAfterDelay delay (fn msg)

        Http req ->
            Http (ElmLand.Http.map fn req)

        PushUrl string ->
            PushUrl string

        ReplaceUrl string ->
            ReplaceUrl string

        Back amount ->
            Back amount

        Forward amount ->
            Forward amount

        Load url ->
            Load url

        Reload ->
            Reload

        ReloadAndSkipCache ->
            ReloadAndSkipCache

        Focus id toMsg ->
            Focus id (toMsg >> fn)

        Blur id toMsg ->
            Blur id (toMsg >> fn)

        GetViewport toMsg ->
            GetViewport (toMsg >> fn)

        GetViewportOf id toMsg ->
            GetViewportOf id (toMsg >> fn)

        SetViewport x y msg ->
            SetViewport x y (msg |> fn)

        SetViewportOf id x y toMsg ->
            SetViewportOf id x y (toMsg >> fn)

        GetElement id toMsg ->
            GetElement id (toMsg >> fn)

        Broadcast event ->
            Broadcast event

        Custom customEffect ->
            Custom (fnCustom customEffect)


toCmd :
    (custom -> Url -> Browser.Navigation.Key -> shared -> ( shared, Cmd msg ))
    -> Effect custom msg
    -> Subscription msg
    -> Url
    -> Browser.Navigation.Key
    -> shared
    -> ( shared, Cmd msg )
toCmd toCustomEffect effect subscription url key shared =
    case effect of
        None ->
            ( shared, Cmd.none )

        Batch children ->
            children
                |> List.foldl
                    (\childEffect ( innerShared, cmds ) ->
                        let
                            ( newModel, newCmd ) =
                                toCmd toCustomEffect childEffect subscription url key innerShared
                        in
                        ( newModel, cmds ++ [ newCmd ] )
                    )
                    ( shared, [] )
                |> Tuple.mapSecond Cmd.batch

        SendMsg msg ->
            ( shared
            , Task.succeed msg
                |> Task.perform identity
            )

        SendMsgAfterDelay delay msg ->
            ( shared
            , Process.sleep delay
                |> Task.perform (always msg)
            )

        Http req ->
            ( shared, ElmLand.Http.toCmd req )

        PushUrl newUrl ->
            ( shared, Browser.Navigation.pushUrl key newUrl )

        ReplaceUrl newUrl ->
            ( shared, Browser.Navigation.replaceUrl key newUrl )

        Back n ->
            ( shared, Browser.Navigation.back key n )

        Forward n ->
            ( shared, Browser.Navigation.forward key n )

        Load newUrl ->
            ( shared, Browser.Navigation.load newUrl )

        Reload ->
            ( shared, Browser.Navigation.reload )

        ReloadAndSkipCache ->
            ( shared, Browser.Navigation.reloadAndSkipCache )

        Focus id toMsg ->
            ( shared, Browser.Dom.focus id |> Task.mapError (always ()) |> Task.attempt toMsg )

        Blur id toMsg ->
            ( shared, Browser.Dom.blur id |> Task.mapError (always ()) |> Task.attempt toMsg )

        GetViewport toMsg ->
            ( shared, Browser.Dom.getViewport |> Task.attempt toMsg )

        GetViewportOf id toMsg ->
            ( shared, Browser.Dom.getViewportOf id |> Task.mapError (always ()) |> Task.attempt toMsg )

        SetViewport x y msg ->
            ( shared, Browser.Dom.setViewport x y |> Task.perform (always msg) )

        SetViewportOf id x y toMsg ->
            ( shared, Browser.Dom.setViewportOf id x y |> Task.mapError (always ()) |> Task.attempt toMsg )

        GetElement id toMsg ->
            ( shared, Browser.Dom.getElement id |> Task.mapError (always ()) |> Task.attempt toMsg )

        Broadcast event ->
            ( shared
            , Subscription.onEvent event subscription
                |> List.map (Task.perform identity << Task.succeed)
                |> Cmd.batch
            )

        Custom customEffect ->
            toCustomEffect customEffect url key shared
