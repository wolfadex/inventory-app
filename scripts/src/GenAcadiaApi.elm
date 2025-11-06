module GenAcadiaApi exposing (run)

import BackendTask
import BackendTask.File
import Elm
import Elm.Annotation
import Elm.Arg
import Elm.Case
import Elm.Declare
import Elm.Op
import Elm.Parser
import Elm.Syntax.Declaration
import Elm.Syntax.Expression
import Elm.Syntax.Node
import Elm.Syntax.Type
import Elm.Syntax.TypeAnnotation
import FatalError
import Pages.Script exposing (Script)
import Set exposing (Set)


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
                        |> List.sortBy
                            (\(Elm.Syntax.Node.Node _ declaration) ->
                                case declaration of
                                    Elm.Syntax.Declaration.FunctionDeclaration _ ->
                                        5

                                    Elm.Syntax.Declaration.AliasDeclaration _ ->
                                        4

                                    Elm.Syntax.Declaration.CustomTypeDeclaration _ ->
                                        3

                                    Elm.Syntax.Declaration.PortDeclaration _ ->
                                        2

                                    Elm.Syntax.Declaration.InfixDeclaration _ ->
                                        1

                                    Elm.Syntax.Declaration.Destructuring _ _ ->
                                        0
                            )
                        |> List.foldl
                            (\(Elm.Syntax.Node.Node _ declaration) prevDecs ->
                                case declaration of
                                    Elm.Syntax.Declaration.FunctionDeclaration function ->
                                        functionToCodecs prevDecs function

                                    Elm.Syntax.Declaration.AliasDeclaration typeAlias ->
                                        let
                                            (Elm.Syntax.Node.Node _ name) =
                                                typeAlias.name

                                            (Elm.Syntax.Node.Node _ typeAnnotation) =
                                                typeAlias.typeAnnotation
                                        in
                                        typeAnnotationToCodecDeclaration prevDecs name typeAnnotation

                                    Elm.Syntax.Declaration.CustomTypeDeclaration type_ ->
                                        customTypeToCodec prevDecs type_

                                    Elm.Syntax.Declaration.PortDeclaration _ ->
                                        prevDecs

                                    Elm.Syntax.Declaration.InfixDeclaration _ ->
                                        prevDecs

                                    Elm.Syntax.Declaration.Destructuring _ _ ->
                                        prevDecs
                            )
                            ( [], Set.empty )
                        |> Tuple.first
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


functionToCodecs : ( List (Result String Elm.Declaration), Set String ) -> Elm.Syntax.Expression.Function -> ( List (Result String Elm.Declaration), Set String )
functionToCodecs ( decs, knownNames ) function =
    case function.signature of
        Nothing ->
            ( decs, knownNames )

        Just (Elm.Syntax.Node.Node _ signature) ->
            let
                (Elm.Syntax.Node.Node _ name) =
                    signature.name

                (Elm.Syntax.Node.Node _ typeAnnotation) =
                    signature.typeAnnotation
            in
            case typeAnnotation of
                Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation (Elm.Syntax.Node.Node _ _) (Elm.Syntax.Node.Node _ typeAnnoTo) ->
                    case typeAnnoTo of
                        Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ ( moduleName, string )) args ->
                            case ( moduleName, string ) of
                                ( [ "Acadia", "Transaction" ], "Transaction" ) ->
                                    case args of
                                        [ Elm.Syntax.Node.Node _ arg ] ->
                                            typeAnnotationToCodecDeclaration ( decs, knownNames )
                                                (name ++ "Response")
                                                arg

                                        _ ->
                                            Debug.todo "this shouldn't happen"

                                _ ->
                                    Debug.todo "Unexpected response type"

                        _ ->
                            Debug.todo "Currently only support Acadia endpoints with a single argument"

                Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ ( moduleName, string )) args ->
                    case ( moduleName, string ) of
                        ( [ "Acadia", "Transaction" ], "Transaction" ) ->
                            case args of
                                [ Elm.Syntax.Node.Node _ arg ] ->
                                    typeAnnotationToCodecDeclaration ( decs, knownNames )
                                        (name ++ "Response")
                                        arg

                                _ ->
                                    Debug.todo "this shouldn't happen"

                        _ ->
                            Debug.todo "Unexpected response type"

                _ ->
                    typeAnnotationToCodecDeclaration ( decs, knownNames ) name typeAnnotation


typeAnnotationToCodecDeclaration : ( List (Result String Elm.Declaration), Set String ) -> String -> Elm.Syntax.TypeAnnotation.TypeAnnotation -> ( List (Result String Elm.Declaration), Set String )
typeAnnotationToCodecDeclaration ( decs, knownNames ) name typeAnnotation =
    if Set.member (codecifyName name) knownNames then
        ( decs, knownNames )

    else
        typeAnnotationToCodec name typeAnnotation
            |> skipMap (Elm.declaration (codecifyName name))
            |> skippableToMaybe
            |> (\maybeDec ->
                    case maybeDec of
                        Nothing ->
                            ( decs, knownNames )

                        Just dec ->
                            ( dec :: decs, Set.insert (codecifyName name) knownNames )
               )


typeAnnotationToCodec : String -> Elm.Syntax.TypeAnnotation.TypeAnnotation -> SkippableResult String Elm.Expression
typeAnnotationToCodec name typeAnnotation =
    case typeAnnotation of
        Elm.Syntax.TypeAnnotation.GenericType string ->
            SErr "Generics are unsupported"

        Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ namedType) args ->
            typeTypeAnnotationToCodec namedType args

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
                    skipMap2
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
                        (typeAnnotationToCodec "" typeAnnoA)
                        (typeAnnotationToCodec "" typeAnnoB)

                _ ->
                    SErr "Invalid tuple size"

        Elm.Syntax.TypeAnnotation.Record recordDefinition ->
            recordDefinition
                |> List.map
                    (\(Elm.Syntax.Node.Node _ ( Elm.Syntax.Node.Node _ fieldName, Elm.Syntax.Node.Node _ fieldAnno )) ->
                        (case fieldAnno of
                            Elm.Syntax.TypeAnnotation.GenericType _ ->
                                SErr "Generics are unsupported"

                            Elm.Syntax.TypeAnnotation.Typed (Elm.Syntax.Node.Node _ namedType) args ->
                                typeTypeAnnotationToCodec namedType args

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
                                        { importFrom = [ "Backend" ]
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

        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation (Elm.Syntax.Node.Node _ typeAnnoFrom) (Elm.Syntax.Node.Node _ typeAnnoTo) ->
            SErr "Function typess unsupported"


typeTypeAnnotationToCodec : ( List String, String ) -> List (Elm.Syntax.Node.Node Elm.Syntax.TypeAnnotation.TypeAnnotation) -> SkippableResult String Elm.Expression
typeTypeAnnotationToCodec ( moduleName, string ) args =
    case ( moduleName, string ) of
        ( [], "String" ) ->
            Elm.value
                { importFrom = [ "Serialize" ]
                , name = "string"
                , annotation = Nothing
                }
                |> SOk

        ( [], "Int" ) ->
            Elm.value
                { importFrom = [ "Serialize" ]
                , name = "int"
                , annotation = Nothing
                }
                |> SOk

        ( [], "Float" ) ->
            Elm.value
                { importFrom = [ "Serialize" ]
                , name = "float"
                , annotation = Nothing
                }
                |> SOk

        ( [], "Bool" ) ->
            Elm.value
                { importFrom = [ "Serialize" ]
                , name = "bool"
                , annotation = Nothing
                }
                |> SOk

        ( [], "Char" ) ->
            Elm.value
                { importFrom = [ "Serialize" ]
                , name = "char"
                , annotation = Nothing
                }
                |> SOk

        ( [], "List" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "list"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [], "Array" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "array"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [ "Array" ], "Array" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "array"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [], "Set" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "set"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [ "Set" ], "Set" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "set"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [], "Dict" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "dict"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [ "Dict" ], "Dict" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "dict"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [], "Maybe" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "maybe"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

        ( [ "Maybe" ], "Maybe" ) ->
            case args of
                [ Elm.Syntax.Node.Node _ arg ] ->
                    typeAnnotationToCodec "" arg
                        |> skipMap
                            (List.singleton
                                >> Elm.apply
                                    (Elm.value
                                        { importFrom = [ "Serialize" ]
                                        , name = "maybe"
                                        , annotation = Nothing
                                        }
                                    )
                            )

                _ ->
                    SErr "Invalid arg count"

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

        ( [ "Acadia", "Transaction" ], "Transaction" ) ->
            Skip

        _ ->
            SErr ("Unsupported type for codec: " ++ Debug.toString ( moduleName, string ))


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


customTypeToCodec : ( List (Result String Elm.Declaration), Set String ) -> Elm.Syntax.Type.Type -> ( List (Result String Elm.Declaration), Set String )
customTypeToCodec ( decs, knownNames ) type_ =
    let
        (Elm.Syntax.Node.Node _ name) =
            type_.name
    in
    if Set.member (codecifyName name) knownNames then
        ( decs, knownNames )

    else
        let
            start =
                Elm.apply
                    (Elm.value
                        { importFrom = [ "Serialize" ]
                        , name = "customType"
                        , annotation = Nothing
                        }
                    )
                    [ Elm.function
                        (List.map
                            (\(Elm.Syntax.Node.Node _ cons) ->
                                let
                                    (Elm.Syntax.Node.Node _ consName) =
                                        cons.name
                                in
                                ( lowerFirstChar consName ++ "Encoder"
                                , Nothing
                                )
                            )
                            type_.constructors
                        )
                        (\conEncoders ->
                            Elm.fn (Elm.Arg.var "value")
                                (\value ->
                                    Elm.Case.custom value
                                        (Elm.Annotation.named [] name)
                                        (List.map2
                                            (\(Elm.Syntax.Node.Node _ cons) enc ->
                                                let
                                                    (Elm.Syntax.Node.Node _ consName) =
                                                        cons.name

                                                    customStart =
                                                        Elm.Arg.customTypeWith
                                                            { importFrom = [ "Backend" ]
                                                            , typeName = name
                                                            , variantName = consName
                                                            }
                                                in
                                                case cons.arguments of
                                                    [] ->
                                                        Elm.Case.branch (customStart identity)
                                                            (\_ -> enc)

                                                    [ _ ] ->
                                                        Elm.Case.branch
                                                            (customStart identity
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                            )
                                                            (\arg1 -> Elm.apply enc [ arg1 ])

                                                    [ _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart Tuple.pair
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                            )
                                                            (\( arg1, arg2 ) -> Elm.apply enc [ arg1, arg2 ])

                                                    [ _, _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart (\arg1 arg2 arg3 -> ( arg1, arg2, arg3 ))
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg3")
                                                            )
                                                            (\( arg1, arg2, arg3 ) -> Elm.apply enc [ arg1, arg2, arg3 ])

                                                    [ _, _, _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart (\arg1 arg2 arg3 arg4 -> ( arg1, arg2, ( arg3, arg4 ) ))
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg3")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg4")
                                                            )
                                                            (\( arg1, arg2, ( arg3, arg4 ) ) -> Elm.apply enc [ arg1, arg2, arg3, arg4 ])

                                                    [ _, _, _, _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart (\arg1 arg2 arg3 arg4 arg5 -> ( arg1, arg2, ( arg3, arg4, arg5 ) ))
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg3")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg4")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg5")
                                                            )
                                                            (\( arg1, arg2, ( arg3, arg4, arg5 ) ) -> Elm.apply enc [ arg1, arg2, arg3, arg4, arg5 ])

                                                    [ _, _, _, _, _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart (\arg1 arg2 arg3 arg4 arg5 arg6 -> ( arg1, arg2, ( arg3, arg4, ( arg5, arg6 ) ) ))
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg3")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg4")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg5")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg6")
                                                            )
                                                            (\( arg1, arg2, ( arg3, arg4, ( arg5, arg6 ) ) ) -> Elm.apply enc [ arg1, arg2, arg3, arg4, arg5, arg6 ])

                                                    [ _, _, _, _, _, _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart (\arg1 arg2 arg3 arg4 arg5 arg6 arg7 -> ( arg1, arg2, ( arg3, arg4, ( arg5, arg6, arg7 ) ) ))
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg3")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg4")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg5")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg6")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg7")
                                                            )
                                                            (\( arg1, arg2, ( arg3, arg4, ( arg5, arg6, arg7 ) ) ) -> Elm.apply enc [ arg1, arg2, arg3, arg4, arg5, arg6, arg7 ])

                                                    [ _, _, _, _, _, _, _, _ ] ->
                                                        Elm.Case.branch
                                                            (customStart (\arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 -> ( arg1, arg2, ( arg3, arg4, ( arg5, arg6, ( arg7, arg8 ) ) ) ))
                                                                |> Elm.Arg.item (Elm.Arg.var "arg1")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg2")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg3")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg4")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg5")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg6")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg7")
                                                                |> Elm.Arg.item (Elm.Arg.var "arg8")
                                                            )
                                                            (\( arg1, arg2, ( arg3, arg4, ( arg5, arg6, ( arg7, arg8 ) ) ) ) -> Elm.apply enc [ arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8 ])

                                                    _ ->
                                                        Debug.todo "You've hit a custom type with more than 8 arguments! Please copy the above approach to handle your arguments"
                                            )
                                            type_.constructors
                                            conEncoders
                                        )
                                )
                        )
                    ]
                    |> SOk
        in
        type_.constructors
            |> List.foldl
                (\(Elm.Syntax.Node.Node _ valueConstructor) skippableFn ->
                    case skippableFn of
                        Skip ->
                            Skip

                        SErr e ->
                            SErr e

                        SOk fn ->
                            let
                                (Elm.Syntax.Node.Node _ consName) =
                                    valueConstructor.name

                                ( varN, argCodecs ) =
                                    case valueConstructor.arguments of
                                        [] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant0"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant1"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant2"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2, Elm.Syntax.Node.Node _ arg3 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant3"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              , typeAnnotationToCodec "" arg3
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2, Elm.Syntax.Node.Node _ arg3, Elm.Syntax.Node.Node _ arg4 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant4"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              , typeAnnotationToCodec "" arg3
                                              , typeAnnotationToCodec "" arg4
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2, Elm.Syntax.Node.Node _ arg3, Elm.Syntax.Node.Node _ arg4, Elm.Syntax.Node.Node _ arg5 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant5"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              , typeAnnotationToCodec "" arg3
                                              , typeAnnotationToCodec "" arg4
                                              , typeAnnotationToCodec "" arg5
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2, Elm.Syntax.Node.Node _ arg3, Elm.Syntax.Node.Node _ arg4, Elm.Syntax.Node.Node _ arg5, Elm.Syntax.Node.Node _ arg6 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant6"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              , typeAnnotationToCodec "" arg3
                                              , typeAnnotationToCodec "" arg4
                                              , typeAnnotationToCodec "" arg5
                                              , typeAnnotationToCodec "" arg6
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2, Elm.Syntax.Node.Node _ arg3, Elm.Syntax.Node.Node _ arg4, Elm.Syntax.Node.Node _ arg5, Elm.Syntax.Node.Node _ arg6, Elm.Syntax.Node.Node _ arg7 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant7"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              , typeAnnotationToCodec "" arg3
                                              , typeAnnotationToCodec "" arg4
                                              , typeAnnotationToCodec "" arg5
                                              , typeAnnotationToCodec "" arg6
                                              , typeAnnotationToCodec "" arg7
                                              ]
                                            )

                                        [ Elm.Syntax.Node.Node _ arg1, Elm.Syntax.Node.Node _ arg2, Elm.Syntax.Node.Node _ arg3, Elm.Syntax.Node.Node _ arg4, Elm.Syntax.Node.Node _ arg5, Elm.Syntax.Node.Node _ arg6, Elm.Syntax.Node.Node _ arg7, Elm.Syntax.Node.Node _ arg8 ] ->
                                            ( Elm.value
                                                { importFrom = [ "Serialize" ]
                                                , name = "variant8"
                                                , annotation = Nothing
                                                }
                                            , [ Elm.value
                                                    { importFrom = [ "Backend" ]
                                                    , name = consName
                                                    , annotation = Nothing
                                                    }
                                                    |> SOk
                                              , typeAnnotationToCodec "" arg1
                                              , typeAnnotationToCodec "" arg2
                                              , typeAnnotationToCodec "" arg3
                                              , typeAnnotationToCodec "" arg4
                                              , typeAnnotationToCodec "" arg5
                                              , typeAnnotationToCodec "" arg6
                                              , typeAnnotationToCodec "" arg7
                                              , typeAnnotationToCodec "" arg8
                                              ]
                                            )

                                        _ ->
                                            ( Elm.val "", [ SErr "Too many args in custom type" ] )
                            in
                            combineSkippableResults argCodecs
                                |> skipMap
                                    (\args ->
                                        Elm.Op.pipe
                                            (Elm.apply varN args)
                                            fn
                                    )
                )
                start
            |> skipMap
                (\variantsApplied ->
                    variantsApplied
                        |> Elm.Op.pipe
                            (Elm.value
                                { importFrom = [ "Serialize" ]
                                , name = "finishCustomType"
                                , annotation = Nothing
                                }
                            )
                        |> Elm.declaration (codecifyName name)
                )
            |> skippableToMaybe
            |> (\maybeDec ->
                    case maybeDec of
                        Nothing ->
                            ( decs, knownNames )

                        Just dec ->
                            ( dec :: decs, Set.insert (codecifyName name) knownNames )
               )



--


codecifyName : String -> String
codecifyName name =
    lowerFirstChar name ++ "Codec"


lowerFirstChar : String -> String
lowerFirstChar name =
    case String.uncons name of
        Nothing ->
            name

        Just ( first, rest ) ->
            String.cons (Char.toLower first) rest


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


skipMap2 : (a -> b -> c) -> SkippableResult e a -> SkippableResult e b -> SkippableResult e c
skipMap2 fn res1 res2 =
    case res1 of
        Skip ->
            Skip

        SErr e ->
            SErr e

        SOk a ->
            case res2 of
                Skip ->
                    Skip

                SErr e ->
                    SErr e

                SOk b ->
                    SOk (fn a b)


skippableToMaybe : SkippableResult e a -> Maybe (Result e a)
skippableToMaybe res =
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
