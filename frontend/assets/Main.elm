module Main exposing (..)

-- IMPORTS

import Html exposing (..)
import Html.Events as Events
import Html.Attributes as Attrs
import Http
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode
import Json.Decode.Pipeline as JsonPipeline
import Navigation exposing (Location)
import UrlParser exposing (..)


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { lights : List HueLight
    , groups : List LightGroup
    , route : Route
    }


type alias HueLight =
    { id : String
    , name : String
    , on : Bool
    , bri : Int
    , hue : Maybe Int
    , sat : Maybe Int
    , effect : Maybe String
    }


type alias LightGroup =
    { id : String
    , name : String
    , lights : List String
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
        ( Model [] [] currentRoute
        , getLights
        )



-- UPDATE


type Msg
    = OnLocationChange Location
    | NewLights (Result Http.Error LightsResponse)
    | NewGroups (Result Http.Error GroupsResponse)
    | LightOn String Bool
    | LightBri String Int
    | LightHue String Int
    | LightSat String Int
    | LightUpdated (Result Http.Error ())


updateOn : List HueLight -> String -> Bool -> List HueLight
updateOn lights id on =
    List.map
        (\light ->
            if light.id == id then
                { light | on = on }
            else
                light
        )
        lights


updateBri : List HueLight -> String -> Int -> List HueLight
updateBri lights id bri =
    List.map
        (\light ->
            if light.id == id then
                { light | bri = bri }
            else
                light
        )
        lights


updateHue : List HueLight -> String -> Int -> List HueLight
updateHue lights id hue =
    List.map
        (\light ->
            if light.id == id then
                { light | hue = Just hue }
            else
                light
        )
        lights


updateSat : List HueLight -> String -> Int -> List HueLight
updateSat lights id sat =
    List.map
        (\light ->
            if light.id == id then
                { light | sat = Just sat }
            else
                light
        )
        lights


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        NewLights (Ok response) ->
            ( { model | lights = response.data }, Cmd.none )

        NewLights (Err _) ->
            ( model, Cmd.none )

        NewGroups (Ok response) ->
            ( { model | groups = response.data }, Cmd.none )

        NewGroups (Err _) ->
            ( model, Cmd.none )

        LightOn id on ->
            ( { model | lights = (updateOn model.lights id on) }, lightOn id on )

        LightBri id bri ->
            ( { model | lights = (updateBri model.lights id bri) }, lightBri id bri )

        LightHue id hue ->
            ( { model | lights = (updateHue model.lights id hue) }, lightHue id hue )

        LightSat id sat ->
            ( { model | lights = (updateSat model.lights id sat) }, lightSat id sat )

        LightUpdated _ ->
            ( model, Cmd.none )



-- VIEW


viewSlider : String -> String -> Int -> String -> (Int -> value) -> Html value
viewSlider min max value label onChange =
    let
        toInt =
            \sliderValue ->
                case String.toInt sliderValue of
                    Ok intValue ->
                        intValue

                    Err _ ->
                        0
    in
        Html.label [ Attrs.class "light-card__slider" ]
            [ Html.text label
            , Html.input
                [ Attrs.class "light-card__range"
                , Attrs.type_ "range"
                , Attrs.min min
                , Attrs.max max
                , Attrs.step "1"
                , Attrs.value (toString value)
                , Events.on "change" (JsonDecode.map onChange (JsonDecode.map toInt Events.targetValue))
                ]
                []
            ]


maybeSlider : String -> String -> Maybe Int -> String -> (Int -> msg) -> Html msg
maybeSlider min max value label onChange =
    case value of
        Just intValue ->
            viewSlider min max intValue label onChange

        Nothing ->
            Html.text ""


viewOnOff : String -> Html Msg
viewOnOff lightId =
    Html.div [ Attrs.class "light-card__on-off" ]
        [ Html.button
            [ Attrs.class "light-card__on-off-button"
            , Events.onClick (LightOn lightId True)
            ]
            [ Html.text "On" ]
        , Html.button
            [ Attrs.class "light-card__on-off-button"
            , Events.onClick (LightOn lightId False)
            ]
            [ Html.text "Off" ]
        ]


viewLight : HueLight -> Html Msg
viewLight light =
    Html.div [ Attrs.class "light-card" ]
        [ Html.h2 [ Attrs.class "light-card__title" ] [ Html.text light.name ]
        , viewOnOff light.id
        , viewSlider "0" "255" light.bri "Brightness" (LightBri light.id)
        , maybeSlider "0" "65535" light.hue "Hue" (LightHue light.id)
        , maybeSlider "0" "255" light.sat "Saturation" (LightSat light.id)
        , Html.a [ Attrs.href "/groups" ] [ Html.text "Groups" ]
        ]


viewNotFound : Html Msg
viewNotFound =
    Html.div []
        [ text "Not Found"
        ]


view : Model -> Html Msg
view model =
    case model.route of
        LightsRoute ->
            Html.div [ Attrs.class "light-cards" ]
                (List.map viewLight model.lights)
        GroupsRoute ->
            Html.div []
                [ text "Some groups"
                ]
        NotFoundRoute ->
            viewNotFound



-- SUBSCRIPTIONS


subscriptions : a -> Sub msg
subscriptions model =
    Sub.none



-- HTTP


type alias LightsResponse =
    { data : List HueLight
    }


type alias GroupsResponse =
    { data : List LightGroup
    }


getLights : Cmd Msg
getLights =
    let
        url =
            "/api/lights"
    in
        Http.send NewLights (Http.get url decodeLights)


getGroups : Cmd Msg
getGroups =
    let
        url =
            "/api/groups"
    in
        Http.send NewLights (Http.get url decodeLights)


updateRequest : String -> Http.Body -> Http.Request ()
updateRequest url body =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }


lightOn : String -> Bool -> Cmd Msg
lightOn id on =
    let
        url =
            "/api/lights/hue/" ++ id

        body =
            Http.jsonBody (JsonEncode.object [ ( "on", JsonEncode.bool on ) ])

        request =
            updateRequest url body
    in
        Http.send LightUpdated request


lightBri : String -> Int -> Cmd Msg
lightBri id bri =
    let
        url =
            "/api/lights/hue/" ++ id

        body =
            Http.jsonBody (JsonEncode.object [ ( "bri", JsonEncode.int bri ) ])

        request =
            updateRequest url body
    in
        Http.send LightUpdated request


lightHue : String -> Int -> Cmd Msg
lightHue id hue =
    let
        url =
            "/api/lights/hue/" ++ id

        body =
            Http.jsonBody (JsonEncode.object [ ( "hue", JsonEncode.int hue ) ])

        request =
            updateRequest url body
    in
        Http.send LightUpdated request


lightSat : String -> Int -> Cmd Msg
lightSat id sat =
    let
        url =
            "/api/lights/hue/" ++ id

        body =
            Http.jsonBody (JsonEncode.object [ ( "sat", JsonEncode.int sat ) ])

        request =
            updateRequest url body
    in
        Http.send LightUpdated request


decodeLights : JsonDecode.Decoder LightsResponse
decodeLights =
    JsonPipeline.decode LightsResponse
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



-- ROUTING


type Route
    = LightsRoute
    | GroupsRoute
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ UrlParser.map LightsRoute top
        , UrlParser.map LightsRoute (UrlParser.s "lights")
        , UrlParser.map GroupsRoute (UrlParser.s "groups")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
