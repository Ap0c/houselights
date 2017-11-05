// ----- Imports ----- //

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');


// ----- Config ----- //

module.exports = env => {

    return {

        entry: "./assets/main.js",

        output: {
            path: path.resolve(__dirname, 'dist'),
            filename: 'app.js',
        },

        plugins: [
            new HtmlWebpackPlugin({
                template: './assets/index.html',
            }),
        ],

        devServer: {
            host: "0.0.0.0",
            proxy: {
                "/api": "http://backend:5000",
            },
        },

        module: {
            rules: [{
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack-loader',
            }],
            noParse: /[\/\\]Main\.elm$/,
        },

    };

};
