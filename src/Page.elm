module Page exposing (..)

import Page.Home
import Page.Login


type Page
    = Login Page.Login.Model
    | Home Page.Home.Model


type Msg
    = LoginMsg Page.Login.Msg
    | HomeMsg Page.Home.Msg
