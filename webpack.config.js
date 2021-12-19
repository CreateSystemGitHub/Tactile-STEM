// webpack.config.js
const workBoxWebpackPlugin = require("workbox-webpack-plugin");
const outputPath = path.resolve(__dirname, "public");

module.export  ={
  plugins: [
    new workBoxWebpackPlugin.GenerateSW({
      swDest: outputPath + "/service-worker.js"
    })
  ]
}