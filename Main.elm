module Main exposing (..)

-- IMPORTS

import Html exposing (..)
import Http
import Json.Decode as JsonDecode
import Json.Decode.Pipeline as JsonPipeline


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { lights : List HueLight }


type alias HueLight =
    { id : String
    , name : String
    , on : Bool
    , bri : Int
    , hue : Maybe Int
    , sat : Maybe Int
    , effect : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( Model []
    , getLights
    )



-- UPDATE


type Msg
    = NewLights (Result Http.Error ApiResponse)


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        NewLights (Ok response) ->
            ( Model response.data, Cmd.none )

        NewLights (Err msg) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.ul []
        ( List.map (\light -> Html.p [] [ Html.text light.name ]) model.lights)



-- SUBSCRIPTIONS


subscriptions : a -> Sub msg
subscriptions model =
    Sub.none



-- HTTP


type alias ApiResponse =
    { data : List HueLight
    }


getLights : Cmd Msg
getLights =
    let
        url =
            "/api/lights"
    in
        Http.send NewLights (Http.get url decodeLights)


decodeLights : JsonDecode.Decoder ApiResponse
decodeLights =
    JsonPipeline.decode ApiResponse
        |> JsonPipeline.required "data" (JsonDecode.list decodeLight)


decodeLight : JsonDecode.Decoder HueLight
decodeLight =
    JsonPipeline.decode HueLight
        |> JsonPipeline.required "hue_id" JsonDecode.string
        |> JsonPipeline.required "name" JsonDecode.string
        |> JsonPipeline.required "on" JsonDecode.bool
        |> JsonPipeline.required "bri" JsonDecode.int
        |> JsonPipeline.optional "hue" (JsonDecode.map Just JsonDecode.int) Nothing
        |> JsonPipeline.optional "sat" (JsonDecode.map Just JsonDecode.int) Nothing
        |> JsonPipeline.optional "effect" (JsonDecode.map Just JsonDecode.string) Nothing
