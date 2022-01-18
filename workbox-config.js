module.exports = {
	globDirectory: 'app/',
	globPatterns: [
		'**/*.{jpg,png,csv,mp3,ico,txt,pyt,ltx,db,erb,rb,js,coffee,scss}'
	],
	swDest: 'public/sw.js',
	ignoreURLParametersMatching: [
		/^utm_/,
		/^fbclid$/
	],
	sourcemap: false
};