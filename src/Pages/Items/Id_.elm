module Pages.Items.Id_ exposing
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
import Effect exposing (Effect)
import Endpoints.Api.Items.Id_
import Html
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
    { id : String
    }


type alias Model =
    { layout : Layout.Authenticated.Model
    , itemID : Result String Backend.ItemID
    , item : Response Http.Extended.Error Backend.Item
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
                , itemID = Err ""
                , item = Response.Failure (Http.Extended.Generic "")
                }
        , initAuthenticated =
            \{ currentUser, currentOrganization } layout layoutEffect ->
                let
                    itemID =
                        case Acadia.Uuid.fromHex route.params.id of
                            Nothing ->
                                Err "Invalid item id"

                            Just id ->
                                Ok (Backend.ItemID id)
                in
                ( { layout = layout
                  , itemID = itemID
                  , item =
                        case itemID of
                            Ok _ ->
                                Response.Loading

                            Err err ->
                                Response.Failure (Http.Extended.Generic err)
                  }
                , Effect.batch
                    [ layoutEffect
                    , case itemID of
                        Err _ ->
                            Effect.none

                        Ok id ->
                            Endpoints.Api.Items.Id_.get ItemLoaded { id = id, organizationID = currentOrganization.id }
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
    | ItemLoaded (Result Http.Extended.Error Backend.Item)


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

        ItemLoaded (Err err) ->
            Layout.Authenticated.updateWithAuth
                { pageModel = model
                , sharedModel = shared
                , route = route
                , update =
                    \_ ->
                        ( { model | item = Response.Failure err }
                        , Effect.none
                        )
                }

        ItemLoaded (Ok item) ->
            Layout.Authenticated.updateWithAuth
                { pageModel = model
                , sharedModel = shared
                , route = route
                , update =
                    \_ ->
                        ( { model | item = Response.Success item }
                        , Effect.none
                        )
                }


view : Context -> Model -> Browser.Document Msg
view { shared } model =
    Layout.Authenticated.view
        { model = model.layout
        , sharedModel = shared
        , toMsg = LayoutMessage
        , title = "Dashboard"
        , body =
            \{ currentUser } ->
                [ Html.text currentUser.primaryEmail
                , Html.p [] [ Html.text "Lorem ipsum" ]
                ]
        }
