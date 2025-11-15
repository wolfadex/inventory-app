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
import Ui.Button
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
    , addItemUnitType : Backend.UnitType
    , addItemImperialVolumeUnit : Backend.ImperialVolumeUnit
    , addItemMetricVolumeUnit : Backend.MetricVolumeUnit
    , addItemImperialMassUnit : Backend.ImperialMassUnit
    , addItemMetricMassUnit : Backend.MetricMassUnit
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
                , addItemUnitType = Backend.Imperial
                , addItemImperialVolumeUnit = Backend.Cup
                , addItemMetricVolumeUnit = Backend.Liter
                , addItemImperialMassUnit = Backend.Pound
                , addItemMetricMassUnit = Backend.Kilogram
                }
        , initAuthenticated =
            \{ currentUser, currentOrganization } layout layoutEffect ->
                ( { layout = layout
                  , items = Response.Loading
                  , addItemSubmit = Submit.Fresh
                  , addItemName = ""
                  , addItemQuantity = "0"
                  , addItemUnitStyle = Backend.Count
                  , addItemUnitType = Backend.Imperial
                  , addItemImperialVolumeUnit = Backend.Cup
                  , addItemMetricVolumeUnit = Backend.Liter
                  , addItemImperialMassUnit = Backend.Pound
                  , addItemMetricMassUnit = Backend.Kilogram
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
    | UserSelectedUnitType Backend.UnitType
    | UserSelectedImperialVolumeUnit Backend.ImperialVolumeUnit
    | UserSelectedMetricVolumeUnit Backend.MetricVolumeUnit
    | UserSelectedImperialMassUnit Backend.ImperialMassUnit
    | UserSelectedMetricMassUnit Backend.MetricMassUnit
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
                        case String.toFloat model.addItemQuantity of
                            Nothing ->
                                ( { model
                                    | addItemSubmit =
                                        Submit.Failed
                                            (Http.Extended.Field
                                                { name = "quantity"
                                                , message = "Invalid quantity"
                                                }
                                            )
                                  }
                                , Effect.none
                                )

                            Just quantity ->
                                ( { model | addItemSubmit = Submit.Submitting }
                                , Endpoints.Api.OrganizationId_.Items.post ItemCreated
                                    { organizationID = currentOrganization.id
                                    , name = model.addItemName

                                    -- , quantity = quantity
                                    , unitStyle = model.addItemUnitStyle
                                    , unitType = model.addItemUnitType
                                    , imperialVolumeUnit = model.addItemImperialVolumeUnit
                                    , metricVolumeUnit = model.addItemMetricVolumeUnit
                                    , imperialMassUnit = model.addItemImperialMassUnit
                                    , metricMassUnit = model.addItemMetricMassUnit
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

        UserSelectedUnitType unitType ->
            ( { model | addItemUnitType = unitType }
            , Effect.none
            )

        UserSelectedImperialVolumeUnit unit ->
            ( { model | addItemImperialVolumeUnit = unit }
            , Effect.none
            )

        UserSelectedMetricVolumeUnit unit ->
            ( { model | addItemMetricVolumeUnit = unit }
            , Effect.none
            )

        UserSelectedImperialMassUnit unit ->
            ( { model | addItemImperialMassUnit = unit }
            , Effect.none
            )

        UserSelectedMetricMassUnit unit ->
            ( { model | addItemMetricMassUnit = unit }
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
                                    , let
                                        unitSelect { value, valueToString, options, onSelect } =
                                            Ui.Select.view
                                                { name = "units"
                                                , value = Just value
                                                , toStringValue = valueToString
                                                , options = options
                                                , onSelect = Maybe.withDefault value >> onSelect
                                                , label = "Unit style"
                                                , submit = model.addItemSubmit
                                                }
                                                []
                                      in
                                      case model.addItemUnitStyle of
                                        Backend.Count ->
                                            Html.text ""

                                        Backend.Volume ->
                                            case model.addItemUnitType of
                                                Backend.Imperial ->
                                                    unitSelect
                                                        { value = model.addItemImperialVolumeUnit
                                                        , valueToString = imperialVolumeUnitToString
                                                        , options =
                                                            [ { value = Backend.Gallon, label = "gal" }
                                                            , { value = Backend.Quart, label = "qt" }
                                                            , { value = Backend.Pint, label = "pt" }
                                                            , { value = Backend.Cup, label = "cup" }
                                                            , { value = Backend.FluidOunce, label = "fl oz" }
                                                            , { value = Backend.Tablespoon, label = "Tbsp" }
                                                            , { value = Backend.Teaspoon, label = "tsp" }
                                                            ]
                                                        , onSelect = UserSelectedImperialVolumeUnit
                                                        }

                                                Backend.Metric ->
                                                    unitSelect
                                                        { value = model.addItemMetricVolumeUnit
                                                        , valueToString = metricVolumeUnitToString
                                                        , options =
                                                            [ { value = Backend.Liter, label = "l" }
                                                            , { value = Backend.Milliliter, label = "ml" }
                                                            ]
                                                        , onSelect = UserSelectedMetricVolumeUnit
                                                        }

                                        Backend.Mass ->
                                            case model.addItemUnitType of
                                                Backend.Imperial ->
                                                    unitSelect
                                                        { value = model.addItemImperialMassUnit
                                                        , valueToString = imperialMassUnitToString
                                                        , options =
                                                            [ { value = Backend.Pound, label = "lb" }
                                                            , { value = Backend.Ounce, label = "oz" }
                                                            ]
                                                        , onSelect = UserSelectedImperialMassUnit
                                                        }

                                                Backend.Metric ->
                                                    unitSelect
                                                        { value = model.addItemMetricMassUnit
                                                        , valueToString = metricMassUnitToString
                                                        , options =
                                                            [ { value = Backend.Kilogram, label = "kg" }
                                                            , { value = Backend.Gram, label = "g" }
                                                            ]
                                                        , onSelect = UserSelectedMetricMassUnit
                                                        }
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
                                , Html.fieldset [ Html.Attributes.attribute "role" "group" ]
                                    [ Ui.Button.basic
                                        { label = "Imperial"
                                        , onClick = UserSelectedUnitType Backend.Imperial
                                        }
                                        [ Html.Attributes.class "secondary"
                                        , Html.Attributes.class <|
                                            if model.addItemUnitType == Backend.Imperial then
                                                ""

                                            else
                                                "outline"
                                        ]
                                    , Ui.Button.basic
                                        { label = "Metric"
                                        , onClick = UserSelectedUnitType Backend.Metric
                                        }
                                        [ Html.Attributes.class "secondary"
                                        , Html.Attributes.class <|
                                            if model.addItemUnitType == Backend.Metric then
                                                ""

                                            else
                                                "outline"
                                        ]
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
        , Html.text ": _qty_ "
        , Html.text <|
            case item.unitStyle of
                Backend.Count ->
                    ""

                Backend.Volume ->
                    case item.unitType of
                        Backend.Imperial ->
                            imperialVolumeUnitToString item.imperialVolumeUnit

                        Backend.Metric ->
                            metricVolumeUnitToString item.metricVolumeUnit

                Backend.Mass ->
                    case item.unitType of
                        Backend.Imperial ->
                            imperialMassUnitToString item.imperialMassUnit

                        Backend.Metric ->
                            metricMassUnitToString item.metricMassUnit
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


imperialVolumeUnitToString : Backend.ImperialVolumeUnit -> String
imperialVolumeUnitToString unit =
    case unit of
        Backend.Gallon ->
            "gal"

        Backend.Quart ->
            "qt"

        Backend.Pint ->
            "pt"

        Backend.Cup ->
            "cup"

        Backend.FluidOunce ->
            "fl oz"

        Backend.Tablespoon ->
            "Tbsp"

        Backend.Teaspoon ->
            "tsp"


imperialMassUnitToString : Backend.ImperialMassUnit -> String
imperialMassUnitToString unit =
    case unit of
        Backend.Pound ->
            "lb"

        Backend.Ounce ->
            "oz"


metricVolumeUnitToString : Backend.MetricVolumeUnit -> String
metricVolumeUnitToString unit =
    case unit of
        Backend.Liter ->
            "l"

        Backend.Milliliter ->
            "ml"


metricMassUnitToString : Backend.MetricMassUnit -> String
metricMassUnitToString unit =
    case unit of
        Backend.Kilogram ->
            "kg"

        Backend.Gram ->
            "g"
