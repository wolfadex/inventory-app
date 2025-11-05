module GenAcadiaApi exposing (run)

import BackendTask
import BackendTask.File
import Elm
import Elm.Annotation
import Elm.Arg
import Elm.Declare
import Elm.Op
import Elm.Parser
import Elm.Syntax.Declaration
import Elm.Syntax.Node
import Elm.Syntax.TypeAnnotation
import FatalError
import Pages.Script exposing (Script)


run : Script
run =
    Pages.Script.withoutCliOptions
        -- (Pages.Script.log "Hello from elm-pages Scripts!")
        (BackendTask.File.rawFile "gen/Backend.elm"
            |> BackendTask.allowFatal
            |> BackendTask.andThen
                (Elm.Parser.parseToFile
                    >> Result.mapError (\_ -> FatalError.fromString "Failed to parse the generated Backend.elm file")
                    >> BackendTask.fromResult
                )
            |> BackendTask.andThen
                (\elmFile ->
                    elmFile.declarations
                        |> List.filterMap
                            (\(Elm.Syntax.Node.Node _ declaration) ->
                                case declaration of
                                    Elm.Syntax.Declaration.FunctionDeclaration function ->
                                        -- Debug.todo ""
                                        Nothing

                                    Elm.Syntax.Declaration.AliasDeclaration typeAlias ->
                                        let
                                            (Elm.Syntax.Node.Node _ name) =
                                                typeAlias.name

                                            (Elm.Syntax.Node.Node _ typeAnnotation) =
                                                typeAlias.typeAnnotation
                                        in
                                        typeAnnotationToCodec name typeAnnotation
                                            |> skipMap (Elm.declaration (codecifyName name))
                                            |> skipMapToMaybe

                                    Elm.Syntax.Declaration.CustomTypeDeclaration type_ ->
                                        -- Debug.todo ""
                                        Nothing

                                    Elm.Syntax.Declaration.PortDeclaration _ ->
                                        Nothing

                                    Elm.Syntax.Declaration.InfixDeclaration _ ->
                                        Nothing

                                    Elm.Syntax.Declaration.Destructuring _ _ ->
                                        Nothing
                            )
                        |> combineResults
                        |> Result.map (Elm.file [ "Acadia", "Api" ])
                        |> Result.mapError FatalError.fromString
                        |> BackendTask.fromResult
                )
            |> BackendTask.andThen
                (\apiFile ->
                    Pages.Script.writeFile
                        { path = "gen/" ++ apiFile.path
                        , body = apiFile.contents
                        }
                        |> BackendTask.allowFatal
                )
        )


codecifyName : String -> String
codecifyName name =
    (case String.uncons name of
        Nothing ->
            name

        Just ( first, rest ) ->
            String.cons (Char.toLower first) rest
    )
        ++ "Codec"


typeAnnotationToCodec : String -> Elm.Syntax.TypeAnnotation.TypeAnnotation -> SkippableResult String Elm.Expression
typeAnnotationToCodec name typeAnnotation =
    case typeAnnotation of
        Elm.Syntax.TypeAnnotation.GenericType string ->
            SErr "Generics are unsupported"

        Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ ( moduleName, string )) args ->
            -- (List (Elm.Syntax.Node.Node _ typeAnno)) ->
            Debug.todo ""

        Elm.Syntax.TypeAnnotation.Unit ->
            Elm.value
                { importFrom = [ "Serialize" ]
                , name = "unit"
                , annotation = Nothing
                }
                |> SOk

        Elm.Syntax.TypeAnnotation.Tupled parts ->
            case parts of
                [ Elm.Syntax.Node.Node _ typeAnnoA, Elm.Syntax.Node.Node _ typeAnnoB ] ->
                    Result.map2
                        (\annoA annoB ->
                            Elm.fn2
                                (Elm.Arg.varWith "codecA" annoA)
                                (Elm.Arg.varWith "codecB" annoB)
                                (\codecA codecB ->
                                    Elm.apply
                                        (Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "tuple"
                                            , annotation = Nothing
                                            }
                                        )
                                        [ codecA, codecB ]
                                )
                        )
                        (typeAnnotationToCodecAnnotation typeAnnoA)
                        (typeAnnotationToCodecAnnotation typeAnnoB)
                        |> skipFromResult

                _ ->
                    SErr "Invalid tuple size"

        Elm.Syntax.TypeAnnotation.Record recordDefinition ->
            recordDefinition
                |> List.map
                    (\(Elm.Syntax.Node.Node _ ( Elm.Syntax.Node.Node _ fieldName, Elm.Syntax.Node.Node _ fieldAnno )) ->
                        (case fieldAnno of
                            Elm.Syntax.TypeAnnotation.GenericType _ ->
                                SErr "Generics are unsupported"

                            Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ ( moduleName, string )) args ->
                                case ( moduleName, string ) of
                                    ( [], "String" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "string"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [], _ ) ->
                                        Elm.val (codecifyName string)
                                            |> SOk

                                    ( [ "Time" ], "Posix" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "time"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Uuid" ], "Uuid" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "uuid"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Int8" ], "Int8" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "int8"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Int16" ], "Int16" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "int16"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Int32" ], "Int32" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "int32"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Int64" ], "Int64" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "int64"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "UInt8" ], "UInt8" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "uint8"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "UInt16" ], "UInt16" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "uint16"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "UInt32" ], "UInt32" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "uint32"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "UInt64" ], "UInt64" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "uint64"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Float32" ], "Float32" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "float32"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Float64" ], "Float64" ) ->
                                        Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "float64"
                                            , annotation = Nothing
                                            }
                                            |> SOk

                                    ( [ "Password" ], "Hash" ) ->
                                        Skip

                                    _ ->
                                        Debug.todo (String.join "." moduleName ++ "." ++ string)

                            Elm.Syntax.TypeAnnotation.Unit ->
                                Elm.value
                                    { importFrom = [ "Serialize" ]
                                    , name = "unit"
                                    , annotation = Nothing
                                    }
                                    |> SOk

                            Elm.Syntax.TypeAnnotation.Tupled parts ->
                                -- case parts of
                                --     [ Elm.Syntax.Node.Node _ typeAnnoA, Elm.Syntax.Node.Node _ typeAnnoB ] ->
                                --         Result.map2
                                --             (\a b ->
                                --                 [ Elm.Annotation.tuple a b
                                --                 ]
                                --                     |> toAnno
                                --             )
                                --             (typeAnnotationToCodecAnnotation typeAnnoA)
                                --             (typeAnnotationToCodecAnnotation typeAnnoB)
                                --     _ ->
                                --         Err "Invalid tuple size"
                                Debug.todo "tuple"

                            Elm.Syntax.TypeAnnotation.Record recordDef ->
                                Debug.todo "rec"

                            Elm.Syntax.TypeAnnotation.GenericRecord _ _ ->
                                SErr "Generic records unsupported"

                            Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation _ _ ->
                                SErr "Function typess unsupported"
                        )
                            |> skipMap
                                (\fieldCodec ->
                                    Elm.apply
                                        (Elm.value
                                            { importFrom = [ "Serialize" ]
                                            , name = "field"
                                            , annotation = Nothing
                                            }
                                        )
                                        [ Elm.get fieldName (Elm.val "")
                                        , fieldCodec
                                        ]
                                )
                    )
                |> combineSkippableResults
                |> skipMap
                    (\fields ->
                        fields
                            |> List.foldl
                                (\field exp ->
                                    exp
                                        |> Elm.Op.pipe field
                                )
                                (Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "record"
                                        , annotation = Nothing
                                        }
                                    )
                                    [ Elm.value
                                        { importFrom = []
                                        , name = name
                                        , annotation = Nothing
                                        }
                                    ]
                                )
                            |> Elm.Op.pipe
                                (Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "finishRecord"
                                        , annotation = Nothing
                                        }
                                    )
                                    []
                                )
                    )

        Elm.Syntax.TypeAnnotation.GenericRecord _ _ ->
            SErr "Generic records unsupported"

        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation _ _ ->
            SErr "Function typess unsupported"


typeAnnotationToCodecAnnotation : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Result String Elm.Annotation.Annotation
typeAnnotationToCodecAnnotation typeAnnotation =
    let
        toAnno =
            Elm.Annotation.namedWith [ "Serialize" ] "Codec"
    in
    case typeAnnotation of
        Elm.Syntax.TypeAnnotation.GenericType _ ->
            Err "Generics are unsupported"

        Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ ( moduleName, string )) args ->
            args
                |> List.map (\(Elm.Syntax.Node.Node _ typeAnno) -> typeAnnotationToCodecAnnotation typeAnno)
                |> combineResults
                |> Result.map
                    (\argAnnos ->
                        [ Elm.Annotation.namedWith moduleName string argAnnos
                        ]
                            |> toAnno
                    )

        Elm.Syntax.TypeAnnotation.Unit ->
            [ Elm.Annotation.unit
            ]
                |> toAnno
                |> Ok

        Elm.Syntax.TypeAnnotation.Tupled parts ->
            case parts of
                [ Elm.Syntax.Node.Node _ typeAnnoA, Elm.Syntax.Node.Node _ typeAnnoB ] ->
                    Result.map2
                        (\a b ->
                            [ Elm.Annotation.tuple a b
                            ]
                                |> toAnno
                        )
                        (typeAnnotationToCodecAnnotation typeAnnoA)
                        (typeAnnotationToCodecAnnotation typeAnnoB)

                _ ->
                    Err "Invalid tuple size"

        Elm.Syntax.TypeAnnotation.Record recordDefinition ->
            Debug.todo ""

        Elm.Syntax.TypeAnnotation.GenericRecord _ _ ->
            Err "Generic records unsupported"

        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation _ _ ->
            Err "Function typess unsupported"


combineResults : List (Result e a) -> Result e (List a)
combineResults =
    List.foldr
        (\next res ->
            case res of
                Err e ->
                    Err e

                Ok ls ->
                    case next of
                        Err e ->
                            Err e

                        Ok a ->
                            Ok (a :: ls)
        )
        (Ok [])


type SkippableResult e a
    = Skip
    | SOk a
    | SErr e


combineSkippableResults : List (SkippableResult e a) -> SkippableResult e (List a)
combineSkippableResults =
    List.foldr
        (\next res ->
            case res of
                Skip ->
                    Skip

                SErr e ->
                    SErr e

                SOk ls ->
                    case next of
                        Skip ->
                            Skip

                        SErr e ->
                            SErr e

                        SOk a ->
                            SOk (a :: ls)
        )
        (SOk [])


skipMap : (a -> b) -> SkippableResult e a -> SkippableResult e b
skipMap fn res =
    case res of
        Skip ->
            Skip

        SErr e ->
            SErr e

        SOk a ->
            SOk (fn a)


skipMapToMaybe : SkippableResult e a -> Maybe (Result e a)
skipMapToMaybe res =
    case res of
        Skip ->
            Nothing

        SOk a ->
            Just (Ok a)

        SErr e ->
            Just (Err e)


skipFromResult : Result e a -> SkippableResult e a
skipFromResult res =
    case res of
        Ok a ->
            SOk a

        Err e ->
            SErr e
