module Pages.Logout exposing
    ( Model, Msg
    , init, update, subscriptions, view
    , Context
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Browser
import Css
import Dict
import Effect exposing (Effect)
import Endpoints.ApiAuthLogout
import Html
import Http.Extended
import Icon
import Route exposing (Route)
import Route.Path
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }



-- MODEL


type alias Model =
    {}


init : Context -> ( Model, Effect Msg )
init _ =
    ( {}
    , Endpoints.ApiAuthLogout.post UserLoggedOut
    )



-- UPDATE


type Msg
    = UserLoggedOut (Result Http.Extended.Error ())


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        UserLoggedOut (Ok ()) ->
            ( model
            , Effect.batch
                [ Effect.broadcast (Subscription.RefreshAuthentication Nothing)
                , Effect.navigateTo { path = Route.Path.HOME_, query = Dict.empty }
                ]
            )

        UserLoggedOut (Err _) ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.none



-- VIEW


view : Context -> Model -> Browser.Document Msg
view _ _ =
    { title = "Logout"
    , body =
        [ Html.main_ [ Css.pageCentered ]
            [ Html.header
                []
                [ Html.h1 [] [ Html.text "Inventory App" ]
                ]
            , Html.text "Logging out..."
            , Icon.loading 64
            ]
        ]
    }
