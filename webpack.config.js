// webpack.config.js
const workboxPlugin = require('workbox-webpack-plugin');

const dist = __dirname + '/dist';

module.exports = {
    plugins: [
        new workboxPlugin({
            globDirectory: __dirname + '/images',
            globPatterns: ['**/*.{html,js,jpg}'],
            swDest: dist + '/sw.js',
        })
    ]
};