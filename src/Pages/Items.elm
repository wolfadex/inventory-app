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
import Endpoints.Api.OrganizationId_.Items
import Html exposing (Html)
import Html.Attributes
import Http.Extended
import Layout.Authenticated
import Response exposing (Response)
import Route exposing (Route)
import Shared
import Submit exposing (Submit)
import Subscription exposing (Subscription)
import Ui.Form
import Ui.NumberInput
import Ui.Select
import Ui.TextInput



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
    , addItemSubmit : Submit () Http.Extended.Error
    , addItemName : String
    , addItemQuantity : String
    , addItemUnitStyle : Backend.UnitStyle
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
                , addItemSubmit = Submit.Fresh
                , addItemName = ""
                , addItemQuantity = "0"
                , addItemUnitStyle = Backend.Count
                }
        , initAuthenticated =
            \{ currentUser, currentOrganization } layout layoutEffect ->
                ( { layout = layout
                  , items = Response.Loading
                  , addItemSubmit = Submit.Fresh
                  , addItemName = ""
                  , addItemQuantity = "0"
                  , addItemUnitStyle = Backend.Count
                  }
                , Effect.batch
                    [ layoutEffect
                    , Endpoints.Api.OrganizationId_.Items.get ItemsLoaded currentOrganization.id
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
    | UserChangedAddItemName String
    | UserChangedAddItemQuantity String
    | UserChanedAddItemUnitStyle Backend.UnitStyle
    | UserSubmittedAddItemForm
    | ItemCreated (Result Http.Extended.Error Backend.Item)


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

        UserSubmittedAddItemForm ->
            Layout.Authenticated.updateWithAuth
                { pageModel = model
                , sharedModel = shared
                , route = route
                , update =
                    \{ currentOrganization } ->
                        ( { model | addItemSubmit = Submit.Submitting }
                        , Endpoints.Api.OrganizationId_.Items.post ItemCreated
                            { organizationID = currentOrganization.id
                            , name = model.addItemName
                            , unitStyle = model.addItemUnitStyle
                            , unitType = Backend.Imperial
                            }
                        )
                }

        UserChangedAddItemName name ->
            ( { model | addItemName = name }
            , Effect.none
            )

        UserChangedAddItemQuantity quantity ->
            ( { model | addItemQuantity = quantity }
            , Effect.none
            )

        UserChanedAddItemUnitStyle unitStyle ->
            ( { model | addItemUnitStyle = unitStyle }
            , Effect.none
            )

        ItemCreated (Err err) ->
            ( { model | addItemSubmit = Submit.Failed (Debug.log "err" err) }
            , Effect.none
            )

        ItemCreated (Ok item) ->
            ( { model
                | addItemSubmit = Submit.Fresh
                , addItemName = ""
                , items =
                    Response.Success <|
                        case model.items of
                            Response.Success items ->
                                item :: items

                            Response.Failure _ ->
                                [ item ]

                            Response.Loading ->
                                [ item ]
              }
            , Effect.none
            )


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
                [ Html.section [ Css.addForm ]
                    [ Html.article []
                        [ Ui.Form.view
                            { name = "add-item"
                            , title = "Add item"
                            , onSubmit = UserSubmittedAddItemForm
                            , submit = model.addItemSubmit
                            , submitLabel = "Add"
                            , additionalButtons = []
                            , fields =
                                [ Ui.TextInput.basic
                                    { name = "name"
                                    , label = "Name"
                                    , value = model.addItemName
                                    , onInput = UserChangedAddItemName
                                    , submit = model.addItemSubmit
                                    }
                                    []
                                , Html.div [ Html.Attributes.class "grid" ]
                                    [ Ui.NumberInput.float
                                        { name = "qauntity"
                                        , label = "Quantity"
                                        , min = 0
                                        , max = 1000
                                        , value = model.addItemQuantity
                                        , onInput = UserChangedAddItemQuantity
                                        , submit = model.addItemSubmit
                                        }
                                        []
                                    , Ui.Select.view
                                        { name = "unitStyle"
                                        , value = Just model.addItemUnitStyle
                                        , toStringValue = unitStyleToString
                                        , options =
                                            [ { value = Backend.Volume, label = "Volume" }
                                            , { value = Backend.Mass, label = "Weight" }
                                            , { value = Backend.Count, label = "Count" }
                                            ]
                                        , onSelect = Maybe.withDefault model.addItemUnitStyle >> UserChanedAddItemUnitStyle
                                        , label = "Unit style"
                                        , submit = model.addItemSubmit
                                        }
                                        []
                                    ]
                                ]
                            }
                        ]
                    ]
                , case model.items of
                    Response.Loading ->
                        Html.article
                            [ Html.Attributes.attribute "aria-busy" "true"
                            , Css.statusCard
                            ]
                            [ Html.text "Gathering your things..."
                            ]

                    Response.Failure err ->
                        Html.article [ Css.statusCard ]
                            [ case err of
                                Http.Extended.Generic error ->
                                    Html.text error

                                Http.Extended.Field { message } ->
                                    Html.text message
                            ]

                    Response.Success items ->
                        Html.section []
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


unitStyleToString : Backend.UnitStyle -> String
unitStyleToString unitStyle =
    case unitStyle of
        Backend.Volume ->
            "Volume"

        Backend.Mass ->
            "Weight"

        Backend.Count ->
            "Count"
