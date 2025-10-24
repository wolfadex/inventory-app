module Page.Login exposing (..)

import Acadia.Transaction
import Backend
import Html exposing (Html)
import Html.Attributes
import Html.Events


type Model
    = Unauthenticated UnauthenticatedModel
    | LoadingUser
    | CreatingOrganization CreateOrganizationModel


type alias UnauthenticatedModel =
    { email : String
    , password : String
    , user : Remote
    }


type Remote
    = Fresh
    | Processing
    | Failure String


type alias CreateOrganizationModel =
    { user : Backend.User
    , name : String
    , organization : Remote
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( Unauthenticated
        { email = ""
        , password = ""
        , user = Fresh
        }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = UserChangedEmail String
    | UserChangedPassword String
    | UserSubmittedAuthForm
    | UserAuthenticated (Maybe ())
      -- | UserLoaded (Maybe ( Backend.User, Maybe Backend.Organization ))
    | UserChangedOrganizationName String
    | UserSubmittedOrganizationCreateForm



-- | OrganizationCreated (Maybe Backend.Organization)


update :
    { msg : Msg
    , model : Model
    , toMsg : Msg -> msg
    , toModel : Model -> model
    , authenticated : Backend.User -> ( model, Cmd msg ) -> ( model, Cmd msg )
    }
    -> ( model, Cmd msg )
update ({ model } as config) =
    case model of
        Unauthenticated unauthenticatedModel ->
            case config.msg of
                UserChangedEmail email ->
                    ( { unauthenticatedModel | email = email }
                        |> Unauthenticated
                        |> config.toModel
                    , Cmd.none
                    )

                UserChangedPassword password ->
                    ( { unauthenticatedModel | password = password }
                        |> Unauthenticated
                        |> config.toModel
                    , Cmd.none
                    )

                UserSubmittedAuthForm ->
                    ( { unauthenticatedModel | user = Processing }
                        |> Unauthenticated
                        |> config.toModel
                    , Backend.authenticate
                        { email = unauthenticatedModel.email
                        , password = unauthenticatedModel.password
                        }
                        |> Acadia.Transaction.attempt "/_endpoints" (UserAuthenticated >> config.toMsg)
                    )

                UserAuthenticated Nothing ->
                    Debug.todo "auth error"

                UserAuthenticated (Just ()) ->
                    ( LoadingUser
                        |> config.toModel
                      -- , Backend.getUserSelf
                      --     |> Acadia.Transaction.attempt "/_endpoints" (UserLoaded >> config.toMsg)
                    , Cmd.none
                    )

                -- UserLoaded Nothing ->
                --     Debug.todo "user load error"
                -- UserLoaded (Just ( user, maybeOrganization )) ->
                --     case maybeOrganization of
                --         Nothing ->
                --             ( { user = user
                --               , name = ""
                --               , organization = Fresh
                --               }
                --                 |> CreatingOrganization
                --                 |> config.toModel
                --             , Cmd.none
                --             )
                --         Just organization ->
                --             ( config.toModel model
                --             , Cmd.none
                --             )
                --                 |> config.authenticated user
                _ ->
                    ( config.toModel model, Cmd.none )

        LoadingUser ->
            Debug.todo ""

        CreatingOrganization createOrganizationModel ->
            case config.msg of
                UserChangedOrganizationName name ->
                    ( { createOrganizationModel | name = name }
                        |> CreatingOrganization
                        |> config.toModel
                    , Cmd.none
                    )

                UserSubmittedOrganizationCreateForm ->
                    ( { createOrganizationModel | organization = Processing }
                        |> CreatingOrganization
                        |> config.toModel
                      -- , Backend.createOrganization { name = createOrganizationModel.name }
                      --     |> Acadia.Transaction.attempt "/_endpoints" (OrganizationCreated >> config.toMsg)
                    , Cmd.none
                    )

                -- OrganizationCreated Nothing ->
                --     Debug.todo "org create error"
                -- OrganizationCreated (Just _) ->
                --     ( config.toModel model
                --     , Cmd.none
                --     )
                --         |> config.authenticated createOrganizationModel.user
                _ ->
                    ( config.toModel model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.style "display" "flex"
        , Html.Attributes.style "flex-direction" "column"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "width" "100vw"
        ]
        [ Html.h1 [] [ Html.text "My App" ]
        , case model of
            Unauthenticated unauthenticatedModel ->
                viewUnauthenticated unauthenticatedModel

            LoadingUser ->
                viewAuthenticating

            CreatingOrganization createOrganizationModel ->
                viewCreateOrganization createOrganizationModel
        ]


viewUnauthenticated : UnauthenticatedModel -> Html Msg
viewUnauthenticated model =
    Html.form
        [ Html.Events.onSubmit UserSubmittedAuthForm
        , Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "5rem 10rem"
        , Html.Attributes.style "gap" "1rem"
        , Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "padding" "1rem"
        , Html.Attributes.style "border-radius" "0.5rem"
        ]
        [ Html.label
            [ Html.Attributes.for "email" ]
            [ Html.text "Email:" ]
        , Html.input
            [ Html.Attributes.type_ "email"
            , Html.Attributes.name "email"
            , Html.Attributes.value model.email
            , Html.Events.onInput UserChangedEmail
            , Html.Attributes.disabled (model.user == Processing)
            ]
            []
        , Html.label
            [ Html.Attributes.for "password" ]
            [ Html.text "Password:" ]
        , Html.input
            [ Html.Attributes.type_ "password"
            , Html.Attributes.name "password"
            , Html.Attributes.value model.password
            , Html.Events.onInput UserChangedPassword
            , Html.Attributes.disabled (model.user == Processing)
            ]
            []
        , Html.button
            [ Html.Attributes.type_ "submit"
            , Html.Attributes.style "grid-column" "2"
            , Html.Attributes.disabled (model.user == Processing)
            ]
            [ Html.text "Login / Sign Up" ]
        , case model.user of
            Failure error ->
                Html.span [ Html.Attributes.style "grid-column" "2" ] [ Html.text error ]

            _ ->
                Html.text ""
        ]


viewAuthenticating : Html Msg
viewAuthenticating =
    Html.h2 [] [ Html.text "Logging in ..." ]


viewCreateOrganization : CreateOrganizationModel -> Html Msg
viewCreateOrganization model =
    Html.form
        [ Html.Events.onSubmit UserSubmittedOrganizationCreateForm
        , Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "5rem 10rem"
        , Html.Attributes.style "gap" "1rem"
        , Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "padding" "1rem"
        , Html.Attributes.style "border-radius" "0.5rem"
        ]
        [ Html.label
            [ Html.Attributes.for "name" ]
            [ Html.text "Organization Name:" ]
        , Html.input
            [ Html.Attributes.name "name"
            , Html.Attributes.value model.name
            , Html.Events.onInput UserChangedOrganizationName
            , Html.Attributes.disabled (model.organization == Processing)
            ]
            []
        , Html.button
            [ Html.Attributes.type_ "submit"
            , Html.Attributes.style "grid-column" "2"
            , Html.Attributes.disabled (model.organization == Processing)
            ]
            [ Html.text "Create Organization" ]
        ]
