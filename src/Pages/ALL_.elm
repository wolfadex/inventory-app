module Pages.ALL_ exposing
    ( Model, Msg
    , init, update, subscriptions, view
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Browser
import Css
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (..)
import Icon
import Levenshtein
import Route exposing (Route)
import Route.Path
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route Params
    }


type alias Params =
    { all_ : List String
    }



-- MODEL


type alias Model =
    {}


init : Context -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = NoOp


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.none



-- VIEW


view : Context -> Model -> Browser.Document Msg
view { route } _ =
    let
        currentPath =
            Route.Path.toString (Route.Path.ALL_ { all_ = route.params.all_ })

        nearest =
            allPaths
                |> List.map (\path -> ( Levenshtein.distance (Route.Path.toString path) currentPath, path ))
                |> List.sortBy Tuple.first
                |> List.take 3
    in
    { title = "404"
    , body =
        [ Html.div [ Css.pageCentered ]
            [ Html.div [] [ Icon.logo 64 ]
            , Html.h1 [] [ Html.text "Page not found" ]
            , Html.p []
                [ Html.text "Did you mean..."
                , Html.ul []
                    (List.map
                        (\( _, path ) ->
                            Html.li []
                                [ Html.a [ Route.Path.href path ]
                                    [ Html.text (Route.Path.toString path) ]
                                ]
                        )
                        nearest
                    )
                ]
            , Html.p []
                [ Html.a [ Route.Path.href Route.Path.Dashboard ]
                    [ Html.text "Back to the homepage" ]
                ]
            ]
        ]
    }


allPaths : List Route.Path.Path
allPaths =
    [ Route.Path.HOME_
    , Route.Path.Dashboard
    , Route.Path.Login
    , Route.Path.Logout
    , Route.Path.OrganizationInit
    , Route.Path.SignUp
    ]
