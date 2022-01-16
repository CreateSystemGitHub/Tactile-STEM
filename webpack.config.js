const path = require('path');
var webpack = require('webpack');
//var CleanWebpackPlugin = require('clean-webpack-plugin');

const SRC = path.resolve(__dirname, 'node_modules');
module.exports = {
  // モード値を production に設定すると最適化された状態で、
  // development に設定するとソースマップ有効でJSファイルが出力される
  mode: 'development',
  entry: 'app/javascript/packs/applicatin.js',
  output: {
    path: path.resolve(__dirname, 'public'),
    filename: 'js/application.js',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
            loader: "babel-loader"
        }
      },
      {
        test: /\.(scss|sass|css)$/,
        exclude: /node_modules/,
        use: ['style-loader', 'css-loader', 'sass-loader']
      },
      /*
      {
        test: /\.css/,
        use: [
          "style-loader",
          {
            loader: "css-loader",
            options: { url: false }
          }
        ]
      },
      */
      {
        test: /\.(png|jpeg)$/,
        use: [
            {
              loader: 'file-loader',
              options: {
                name: '../images/[name].[ext]',                            
                outputPath: '../images/',
                publicPath: 'images/',
                useRelativePaths: true
              }
            }
        ]
      },
      {
        test: /\.(mp3|wav)$/,
        use: [
            {
                loader: 'file-loader',
                options: {                            
                    name: '[path][name].[ext]',                            
                    outputPath: '../audio/',
                    publicPath: 'audio/',
                    useRelativePaths: true
                }
            }
        ]
      }

    ]
  }
};