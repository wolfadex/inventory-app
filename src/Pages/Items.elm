module Pages.Items exposing
    ( Context
    , Model
    , Msg(..)
    , Params
    , init
    , subscriptions
    , update
    , view
    )

import Acadia.Uuid
import Backend
import Browser
import Css
import Effect exposing (Effect)
import Endpoints.Api.Items
import Html exposing (Html)
import Html.Attributes
import Http.Extended
import Layout.Authenticated
import Response exposing (Response)
import Route exposing (Route)
import Shared
import Subscription exposing (Subscription)



-- CONTEXT


type alias Context =
    { shared : Shared.Model
    , route : Route Params
    }


type alias Params =
    ()


type alias Model =
    { layout : Layout.Authenticated.Model
    , items : Response Http.Extended.Error (List Backend.Item)
    }


init : Context -> ( Model, Effect Msg )
init { shared, route } =
    Layout.Authenticated.init
        { route = route
        , sharedModel = shared
        , toMsg = LayoutMessage
        , initUnauthenticated =
            \layout ->
                { layout = layout
                , items = Response.Failure (Http.Extended.Generic "")
                }
        , initAuthenticated =
            \{ currentUser, currentOrganization } layout layoutEffect ->
                ( { layout = layout
                  , items = Response.Loading
                  }
                , Effect.batch
                    [ layoutEffect
                    , Endpoints.Api.Items.get ItemsLoaded currentOrganization.id
                    ]
                )
        }



-- SUBSCRIPTIONS


subscriptions : Context -> Model -> Subscription Msg
subscriptions _ model =
    Layout.Authenticated.subscriptions model.layout
        |> Subscription.map LayoutMessage



-- UPDATE


type Msg
    = LayoutMessage Layout.Authenticated.Msg
    | ItemsLoaded (Result Http.Extended.Error (List Backend.Item))


update : Context -> Msg -> Model -> ( Model, Effect Msg )
update { shared, route } msg model =
    case msg of
        LayoutMessage layoutMsg ->
            Layout.Authenticated.update
                { msg = layoutMsg
                , toMsg = LayoutMessage
                , model = model.layout
                , toModel = \layout -> { model | layout = layout }
                , sharedModel = shared
                , route = route
                }

        ItemsLoaded (Err err) ->
            Layout.Authenticated.updateWithAuth
                { pageModel = model
                , sharedModel = shared
                , route = route
                , update =
                    \_ ->
                        ( { model | items = Response.Failure err }
                        , Effect.none
                        )
                }

        ItemsLoaded (Ok items) ->
            Layout.Authenticated.updateWithAuth
                { pageModel = model
                , sharedModel = shared
                , route = route
                , update =
                    \_ ->
                        ( { model | items = Response.Success items }
                        , Effect.none
                        )
                }


view : Context -> Model -> Browser.Document Msg
view { shared, route } model =
    Layout.Authenticated.view
        { model = model.layout
        , sharedModel = shared
        , route = route
        , toMsg = LayoutMessage
        , title = "Dashboard"
        , body =
            \{ currentUser } ->
                case model.items of
                    Response.Loading ->
                        [ Html.article
                            [ Html.Attributes.attribute "aria-busy" "true"
                            , Css.statusCard
                            ]
                            [ Html.text "Gathering your things..."
                            ]
                        ]

                    Response.Failure err ->
                        [ Html.article [ Css.statusCard ]
                            [ case err of
                                Http.Extended.Generic error ->
                                    Html.text error

                                Http.Extended.Field { message } ->
                                    Html.text message
                            ]
                        ]

                    Response.Success items ->
                        [ Html.section []
                            [ Html.article []
                                []
                            ]
                        , Html.section []
                            [ case items of
                                [] ->
                                    Html.text "Nothing here yet"

                                _ ->
                                    Html.ul
                                        []
                                        (List.map viewItem items)
                            ]
                        ]
        }


viewItem : Backend.Item -> Html Msg
viewItem item =
    Html.li
        []
        [ Html.text item.name
        ]
