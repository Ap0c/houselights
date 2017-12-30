// ----- Imports ----- //

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');


// ----- Config ----- //

module.exports = env => {

    const isProd = env && env.prod;

    const plugins = [
        new HtmlWebpackPlugin({
            template: './assets/index.html',
        }),
        new ExtractTextPlugin('styles.css'),
    ];

    if (isProd) {
        plugins.push(new UglifyJSPlugin());
    }

    return {

        entry: {
            app: './assets/main.js',
            styles: './assets/stylesheets/main.scss',
        },

        output: {
            path: path.resolve(__dirname, 'dist'),
            filename: '[name].js',
            publicPath: '/',
        },

        plugins,

        devServer: {
            host: "0.0.0.0",
            proxy: {
                "/api": "http://backend:5000",
            },
            historyApiFallback: true,
        },

        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader: 'elm-webpack-loader',
                },
                {
                    test: /\.scss$/,
                    use: ExtractTextPlugin.extract({
                        use: [
                            {
                                loader: 'css-loader',
                                options: {
                                    minimize: isProd,
                                },
                            },
                            {
                                loader: 'sass-loader',
                            },
                        ],
                    }),
                }
            ],
            noParse: /[\/\\]Main\.elm$/,
        },

    };

};
