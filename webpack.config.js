const path    = require("path")
const webpack = require("webpack")

const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts')
const CopyPlugin = require("copy-webpack-plugin");

const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production'

module.exports = {
  mode,
  devtool: "source-map",
  entry: {
    application: [
      "./app/frontend/application.js",
    ],
    active_admin: [
      './app/frontend/active_admin.js',
      './app/frontend/styles/active_admin.scss'
    ]
  },
  module: {
    rules: [
      {
        test: /\.(js|ts)$/,
        include: [
          path.resolve(__dirname, 'node_modules/@hotwired/stimulus'),
          path.resolve(__dirname, 'node_modules/@rails/actioncable'),
          path.resolve(__dirname, 'app/frontend/controllers'),
        ],
        use: ['babel-loader'],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg|ico)$/i,
        use: 'file-loader',
      },
      {
        test: /\.(scss|css)/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      }
    ],
  },
  resolve: {
    modules: ['node_modules', 'node_modules/govuk-frontend/govuk']
  },
  output: {
    filename: "[name].js",
    // we must set publicPath to an empty value to override the default of
    // auto which doesn't work in IE11
    publicPath: '',
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  plugins: [
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
    new webpack.optimize.LimitChunkCountPlugin({ maxChunks: 1 }),
    new CopyPlugin({
      patterns: [
        { from: "node_modules/govuk-frontend/govuk/assets/images", to: "images" },
        { from: "node_modules/govuk-frontend/govuk/assets/fonts", to: "fonts" },
      ],
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      jquery: 'jquery',
      'window.jQuery': 'jquery'
    })
  ]
}
