module Route exposing (..)

import AppUrl exposing (AppUrl)
import Backend
import Url exposing (Url)


type Route
    = Home
    | Login


fromUrl : Url -> Maybe Route
fromUrl url =
    case (AppUrl.fromUrl url).path of
        [] ->
            Just Home

        [ "login" ] ->
            Just Login

        _ ->
            Nothing


toString : Route -> String
toString route =
    case route of
        Home ->
            "/"

        Login ->
            "/login"
