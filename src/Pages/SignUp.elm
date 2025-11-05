module Pages.SignUp exposing
    ( Model, Msg
    , init, update, subscriptions, view
    , Context
    )

{-|

@docs Model, Msg
@docs init, update, subscriptions, view

-}

import Authentication
import Browser
import Css
import Dict
import Effect exposing (Effect)
import Endpoints.ApiAuthSignup
import Html
import Html.Attributes
import Http.Extended
import Icon
import Route exposing (Route)
import Route.Path
import Shared
import Submit exposing (Submit)
import Subscription exposing (Subscription)
import Ui.Form
import Ui.TextInput



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route ()
    }



-- MODEL


type alias Model =
    { email : String
    , password : String
    , name : String
    , submit : Submit String Http.Extended.Error
    }


init : Context -> ( Model, Effect Msg )
init _ =
    ( { email = ""
      , password = ""
      , name = ""
      , submit = Submit.Fresh
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserChangedEmail String
    | UserChangedPassword String
    | UserChangedName String
    | UserSubmittedAuthForm
    | UserSignedUp (Result Http.Extended.Error ())
    | AuthenticationChanged


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared } msg model =
    case msg of
        UserChangedEmail email ->
            ( { model | email = email }
            , Effect.none
            )

        UserChangedPassword password ->
            ( { model | password = password }
            , Effect.none
            )

        UserChangedName name ->
            ( { model | name = name }
            , Effect.none
            )

        UserSubmittedAuthForm ->
            ( { model | submit = Submit.Submitting }
            , Endpoints.ApiAuthSignup.post UserSignedUp
                { email = model.email
                , password = model.password
                , name = model.name
                }
            )

        UserSignedUp (Ok ()) ->
            ( model
            , Effect.broadcast (Subscription.RefreshAuthentication Nothing)
            )

        UserSignedUp (Err err) ->
            ( { model | submit = Submit.Failed err }
            , Effect.none
            )

        AuthenticationChanged ->
            case shared.currentUser of
                Authentication.Unauthenticated ->
                    ( { model
                        | submit =
                            if String.isEmpty model.email && String.isEmpty model.password then
                                Submit.Fresh

                            else
                                Submit.Failed (Http.Extended.Generic "Failed to sign up")
                      }
                    , Effect.none
                    )

                Authentication.Authenticating ->
                    ( model, Effect.none )

                Authentication.Authenticated _ ->
                    ( model
                    , Effect.navigateTo { path = Route.Path.Dashboard, query = Dict.empty }
                    )



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ _ =
    Subscription.onAuthenticationChange AuthenticationChanged



-- VIEW


view : Context -> Model -> Browser.Document Msg
view _ model =
    { title = "Sign up"
    , body =
        [ Html.main_
            [ Css.pageCentered
            ]
            [ Html.header
                []
                [ Icon.logo 64
                , Html.strong [ Html.Attributes.style "font-size" "3rem" ] [ Html.text "Inventory App" ]
                ]
            , Html.article []
                [ Ui.Form.view
                    { name = "signup"
                    , title = "Sign up"
                    , onSubmit = UserSubmittedAuthForm
                    , submit = model.submit
                    , submitLabel = "Sign up"
                    , additionalButtons = []
                    , fields =
                        [ Ui.TextInput.basic
                            { name = "name"
                            , label = "Name"
                            , value = model.name
                            , onInput = UserChangedName
                            , submit = model.submit
                            }
                            []
                        , Ui.TextInput.email
                            { name = "email"
                            , label = "Email"
                            , value = model.email
                            , onInput = UserChangedEmail
                            , submit = model.submit
                            }
                            []
                        , Ui.TextInput.password
                            { name = "password"
                            , label = "Password"
                            , value = model.password
                            , onInput = UserChangedPassword
                            , submit = model.submit
                            }
                            []
                        ]
                    }
                ]
            , Html.footer []
                [ Html.a [ Route.Path.href Route.Path.Login ]
                    [ Html.text "Login" ]
                ]
            ]
        ]
    }
