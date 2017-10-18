module Main exposing (..)

-- IMPORTS

import Html exposing (..)
import Html.Events as Events
import Http
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode
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
    | LightUpdated (Result Http.Error ())
    | LightOn String Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewLights (Ok response) ->
            ( Model response.data, Cmd.none )

        NewLights (Err _) ->
            ( model, Cmd.none )

        LightOn id on ->
            ( model, lightOn id on )

        LightUpdated _ ->
            ( model, Cmd.none )



-- VIEW


viewLight : HueLight -> Html Msg
viewLight light =
    Html.div []
        [ Html.h2 [] [ Html.text light.name ]
        , Html.button [ Events.onClick (LightOn light.id True) ] [ Html.text "On" ]
        , Html.button [ Events.onClick (LightOn light.id False) ] [ Html.text "Off" ]
        ]


view : Model -> Html Msg
view model =
    Html.div []
        (List.map viewLight model.lights)



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


lightOn : String -> Bool -> Cmd Msg
lightOn id on =
    let
        url =
            "/api/lights/hue/" ++ id

        body =
            Http.jsonBody (JsonEncode.object [ ("on", JsonEncode.bool on) ])

        request =
            Http.request
                { method = "PATCH"
                , headers = []
                , url = url
                , body = body
                , expect = Http.expectStringResponse (\_ -> Ok ())
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send LightUpdated request


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
