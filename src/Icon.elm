module Icon exposing
    ( logo
    , loading
    )

import Svg exposing (Svg)
import Svg.Attributes


logo : Int -> Svg msg
logo size =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 400 400"
        , Svg.Attributes.fill "none"
        , Svg.Attributes.width (String.fromInt size)
        , Svg.Attributes.height (String.fromInt size)
        ]
        [ Svg.path
            [ Svg.Attributes.d "M396.408 313.179C382.797 280.624 352.148 66.6928 192.902 69.3208C42.8345 71.7968 -1.21852 239.147 3.39348 324.691C3.59248 328.381 17.7515 337.283 18.0885 322.346C19.4195 263.368 68.9385 86.6798 189.759 93.8188C338.898 102.631 359.087 293.914 379.665 315.691C394.099 330.966 398.585 318.386 396.408 313.179Z"
            , Svg.Attributes.fill "#EF4769"
            ]
            []
        , Svg.path
            [ Svg.Attributes.d "M190.298 99.8668C223.98 102.556 328.112 129.619 360.217 293.993C364.698 316.931 348.428 307.501 341.992 297.618C318.947 262.229 281.148 138.907 186.436 132.218C100.111 126.122 65.1255 269.198 59.2035 304.16C53.2815 339.122 27.7715 308.439 29.4635 297.019C48.7435 166.862 124.591 94.6198 190.298 99.8668Z"
            , Svg.Attributes.fill "#FFEA4F"
            ]
            []
        , Svg.path
            [ Svg.Attributes.d "M194.277 172.66C99.4275 183.08 105.597 297.626 99.5295 311.597C92.6285 327.485 74.9995 326.36 73.0005 314.954C60.6805 244.665 121.474 152.605 189.66 146.75C254.833 141.153 322.48 261.241 326.597 287.312C330.678 313.152 321.107 307.254 312.513 294.731C292.628 265.755 224.728 169.315 194.277 172.66Z"
            , Svg.Attributes.fill "#6CE16C"
            ]
            []
        , Svg.path
            [ Svg.Attributes.d "M113.996 317.261C107.558 280.339 122.244 196.336 167.04 188.64C238.488 176.364 287.167 276.039 286.296 283.924C283.152 312.383 268.074 299.487 264.058 292.616C221.004 218.962 184.49 212.002 179.463 214.106C167.381 219.163 165.968 216.543 138.048 312.502C134.158 325.87 115.834 327.799 113.996 317.261Z"
            , Svg.Attributes.fill "#44BFE1"
            ]
            []
        ]


loading : Svg msg
loading =
    -- <svg fill="hsl(228, 97%, 42%)" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="1" y="1" rx="1" width="10" height="10"><animate id="spinner_c7A9" begin="0;spinner_23zP.end" attributeName="x" dur="0.2s" values="1;13" fill="freeze"/><animate id="spinner_Acnw" begin="spinner_ZmWi.end" attributeName="y" dur="0.2s" values="1;13" fill="freeze"/><animate id="spinner_iIcm" begin="spinner_zfQN.end" attributeName="x" dur="0.2s" values="13;1" fill="freeze"/><animate id="spinner_WX4U" begin="spinner_rRAc.end" attributeName="y" dur="0.2s" values="13;1" fill="freeze"/></rect><rect x="1" y="13" rx="1" width="10" height="10"><animate id="spinner_YLx7" begin="spinner_c7A9.end" attributeName="y" dur="0.2s" values="13;1" fill="freeze"/><animate id="spinner_vwnJ" begin="spinner_Acnw.end" attributeName="x" dur="0.2s" values="1;13" fill="freeze"/><animate id="spinner_KQuy" begin="spinner_iIcm.end" attributeName="y" dur="0.2s" values="1;13" fill="freeze"/><animate id="spinner_arKy" begin="spinner_WX4U.end" attributeName="x" dur="0.2s" values="13;1" fill="freeze"/></rect><rect x="13" y="13" rx="1" width="10" height="10"><animate id="spinner_ZmWi" begin="spinner_YLx7.end" attributeName="x" dur="0.2s" values="13;1" fill="freeze"/><animate id="spinner_zfQN" begin="spinner_vwnJ.end" attributeName="y" dur="0.2s" values="13;1" fill="freeze"/><animate id="spinner_rRAc" begin="spinner_KQuy.end" attributeName="x" dur="0.2s" values="1;13" fill="freeze"/><animate id="spinner_23zP" begin="spinner_arKy.end" attributeName="y" dur="0.2s" values="1;13" fill="freeze"/></rect></svg>

    Svg.svg
        [ Svg.Attributes.fill "hsl(228, 97%, 42%)"
        , Svg.Attributes.viewBox "0 0 24 24"
        ]
        [ Svg.rect
            [ Svg.Attributes.x "1"
            , Svg.Attributes.y "1"
            , Svg.Attributes.rx "1"
            , Svg.Attributes.width "10"
            , Svg.Attributes.height "10"
            ]
            [ Svg.animate
                [ Svg.Attributes.id "spinner_c7A9"
                , Svg.Attributes.begin "0;spinner_23zP.end"
                , Svg.Attributes.attributeName "Svg.Attributes.x"
                , Svg.Attributes.dur "0.2s"
                , Svg.Attributes.values "1;13"
                , Svg.Attributes.fill "freeze"
                ] []
            , Svg.animate
                [ Svg.Attributes.id "spinner_Acnw"
                , Svg.Attributes.begin "spinner_ZmWi.end"
                , Svg.Attributes.attributeName "Svg.Attributes.y"
                , Svg.Attributes.dur "0.2s"
                , Svg.Attributes.values "1;13"
                , Svg.Attributes.fill "freeze"
                ] []
            , Svg.animate
                [ Svg.Attributes.id "spinner_iIcm"
                , Svg.Attributes.begin "spinner_zfQN.end"
                , Svg.Attributes.attributeName "Svg.Attributes.x"
                , Svg.Attributes.dur "0.2s"
                , Svg.Attributes.values "13;1"
                , Svg.Attributes.fill "freeze"
                ] []
            , Svg.animate
                [ Svg.Attributes.id "spinner_WX4U"
                , Svg.Attributes.begin "spinner_rRAc.end"
                , Svg.Attributes.attributeName "Svg.Attributes.y"
                , Svg.Attributes.dur "0.2s"
                , Svg.Attributes.values "13;1"
                , Svg.Attributes.fill "freeze"
                ] []
            ]
        , Svg.rect
                [ Svg.Attributes.x "1"
                , Svg.Attributes.y "13"
                , Svg.Attributes.rx "1"
                , Svg.Attributes.width "10"
                , Svg.Attributes.height "10"
                ]
                [ Svg.animate
                    [ Svg.Attributes.id "spinner_YLx7"
                    , Svg.Attributes.begin "spinner_c7A9.end"
                    , Svg.Attributes.attributeName "Svg.Attributes.y"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "13;1"
                    , Svg.Attributes.fill "freeze"
                    ] []
                , Svg.animate
                    [ Svg.Attributes.id "spinner_vwnJ"
                    , Svg.Attributes.begin "spinner_Acnw.end"
                    , Svg.Attributes.attributeName "Svg.Attributes.x"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "1;13"
                    , Svg.Attributes.fill "freeze"
                    ] []
                , Svg.animate
                    [ Svg.Attributes.id "spinner_KQuy"
                    , Svg.Attributes.begin "spinner_iIcm.end"
                    , Svg.Attributes.attributeName "y"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "1;13"
                    , Svg.Attributes.fill "freeze"
                    ] []
                , Svg.animate
                    [ Svg.Attributes.id "spinner_arKy"
                    , Svg.Attributes.begin "spinner_WX4U.end"
                    , Svg.Attributes.attributeName "x"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "13;1"
                    , Svg.Attributes.fill "freeze"
                    ] []
                ]
            , Svg.rect
                [ Svg.Attributes.x "13"
                , Svg.Attributes.y "13"
                , Svg.Attributes.rx "1"
                , Svg.Attributes.width "10"
                , Svg.Attributes.height "10"
                ]
                [ Svg.animate
                    [ Svg.Attributes.id "spinner_ZmWi"
                    , Svg.Attributes.begin "spinner_YLx7.end"
                    , Svg.Attributes.attributeName "x"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "13;1"
                    , Svg.Attributes.fill "freeze"
                    ] []
                , Svg.animate
                    [ Svg.Attributes.id "spinner_zfQN"
                    , Svg.Attributes.begin "spinner_vwnJ.end"
                    , Svg.Attributes.attributeName "y"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "13;1"
                    , Svg.Attributes.fill "freeze"
                    ] []
                , Svg.animate
                    [ Svg.Attributes.id "spinner_rRAc"
                    , Svg.Attributes.begin "spinner_KQuy.end"
                    , Svg.Attributes.attributeName "x"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "1;13"
                    , Svg.Attributes.fill "freeze"
                    ] []
                , Svg.animate
                    [ Svg.Attributes.id "spinner_23zP"
                    , Svg.Attributes.begin "spinner_arKy.end"
                    , Svg.Attributes.attributeName "y"
                    , Svg.Attributes.dur "0.2s"
                    , Svg.Attributes.values "1;13"
                    , Svg.Attributes.fill "freeze"
                    ] []
                ]
        ]