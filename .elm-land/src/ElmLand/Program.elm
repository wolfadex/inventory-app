-- 📦 Standard module for https://elm.land 🌈 --


module ElmLand.Program exposing
    ( Program, Msg(..)
    , new
    )

{-| The default implementation of an Elm Land program.

If you want to do something fancier, feel free to copy this code
into `src/Main.elm` and use it as a starting point!

@docs Program, Msg
@docs new

-}

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Effect exposing (Effect)
import Html
import Json.Decode as Json
import Json.Encode as Encode
import Pages
import Route exposing (Route)
import Shared
import Subscription exposing (Subscription)
import Url exposing (Url)



-- ELM LAND PROGRAM


type alias Program =
    Platform.Program Json.Value Model Msg


type alias Props =
    { toCmd : Model -> Effect Msg -> ( Model, Cmd Msg )
    , toSub : Subscription Msg -> Sub Msg
    }


new :
    { toCmd : Effect Msg -> Subscription Msg -> Url -> Key -> Shared.Model -> ( Shared.Model, Cmd Msg )
    , toSub : Subscription Msg -> Sub Msg
    }
    -> Program
new options =
    let
        toCmd : Model -> Effect Msg -> ( Model, Cmd Msg )
        toCmd model effect =
            options.toCmd effect (toSubscriptions model) model.url model.url_key model.shared
                |> Tuple.mapFirst (\shared -> { model | shared = shared })

        props : Props
        props =
            { toCmd = toCmd
            , toSub = options.toSub
            }
    in
    Browser.application
        { init = init props
        , update = update props
        , view = view
        , subscriptions = subscriptions props
        , onUrlRequest = Link
        , onUrlChange = Url
        }


type alias Model =
    { data : Json.Value
    , page : Pages.Model
    , shared : Shared.Model
    , url : Url
    , url_key : Key
    , url_confirm : UrlConfirm
    , url_needsPushUrl : Bool
    }


type UrlConfirm
    = None
    | IgnoreNext
    | ConfirmingLink Browser.UrlRequest
    | ConfirmingUrl Url


type alias Flags =
    { data : Json.Value
    , user : Json.Value
    }


{-|


## Expected format:

```json
{
  "data": <stuff from data-page attribute>,
  "user": <user-provided flags>
}
```

-}
decoder : Json.Decoder Flags
decoder =
    Json.map2 Flags
        (Json.field "data" Json.value)
        (Json.field "user" Json.value)


init : Props -> Json.Value -> Url -> Key -> ( Model, Cmd Msg )
init props json url key =
    let
        flags : Flags
        flags =
            Json.decodeValue decoder json
                |> Result.withDefault (Flags Encode.null Encode.null)

        ( shared, sharedEffect ) =
            Shared.init flags.user (route url)

        ( page, pageEffect ) =
            Pages.init url shared

        model : Model
        model =
            { data = flags.data
            , shared = shared
            , page = page
            , url = url
            , url_key = key
            , url_confirm = None
            , url_needsPushUrl = False
            }
    in
    Effect.batch
        [ sharedEffect
            |> Effect.map Shared
        , pageEffect
            |> Effect.map Page
        ]
        |> props.toCmd model



-- UPDATE


type Msg
    = Link UrlRequest
    | Url Url
    | Shared Shared.Msg
    | Page Pages.Msg
    | Batch (List Msg)


update : Props -> Msg -> Model -> ( Model, Cmd Msg )
update props msg model =
    case msg of
        Batch msgs ->
            -- Allows you to send multiple messages at once
            -- which is useful for handling HTTP errors at the root
            -- while still sending the result to the page or original
            -- message handler.
            List.foldl
                (\innerMsg ( m, inCmd ) ->
                    let
                        ( newModel, newCmd ) =
                            update props innerMsg m
                    in
                    ( newModel, Cmd.batch [ inCmd, newCmd ] )
                )
                ( model, Cmd.none )
                msgs

        Link urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.url_key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        Url url ->
            let
                ( newPage, pageEffect ) =
                    Pages.init url model.shared

                newModel =
                    { model | page = newPage, url = url }
            in
            pageEffect
                |> Effect.map Page
                |> props.toCmd newModel
                |> Tuple.mapSecond
                    (\pageCmd ->
                        Cmd.batch
                            [ pageCmd
                            , if model.url_needsPushUrl then
                                Nav.pushUrl model.url_key (Url.toString url)

                              else
                                Cmd.none
                            ]
                    )

        Shared sharedMsg ->
            let
                ( newShared, sharedEffect ) =
                    Shared.update (route model.url) sharedMsg model.shared

                newModel =
                    { model | shared = newShared }
            in
            sharedEffect
                |> Effect.map Shared
                |> props.toCmd newModel

        Page pageMsg ->
            let
                ( newPage, pageEffect ) =
                    Pages.update
                        model.url
                        model.shared
                        pageMsg
                        model.page

                newModel =
                    { model | page = newPage }
            in
            pageEffect
                |> Effect.map Page
                |> props.toCmd newModel


subscriptions : Props -> Model -> Sub Msg
subscriptions props model =
    toSubscriptions model
        |> props.toSub


toSubscriptions : Model -> Subscription Msg
toSubscriptions model =
    Subscription.batch
        [ Shared.subscriptions (route model.url) model.shared
            |> Subscription.map Shared
        , Pages.subscriptions model.url model.shared model.page
            |> Subscription.map Page
        ]


view : Model -> Browser.Document Msg
view model =
    Pages.view model.url model.shared model.page
        |> documentMap Page


route : Url -> Route ()
route url =
    Route.fromUrl () url



-- ELM LAND


documentMap : (a -> b) -> Browser.Document a -> Browser.Document b
documentMap fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }
