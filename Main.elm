module Main exposing (..)

-- IMPORTS

import Html exposing (text)


main : Html.Html msg
main =
    text "Hello World"



-- TYPES


type alias HueWhite =
    { id : String
    , name : String
    , on : Bool
    , bri : Int
    }
