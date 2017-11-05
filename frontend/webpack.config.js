// ----- Imports ----- //

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');


// ----- Config ----- //

module.exports = {
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
    },
    module: {
        rules: [{
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            loader: 'elm-webpack-loader',
        }],
        noParse: /[\/\\]Main\.elm$/,
    }
};
