var compileCJSX = require('broccoli-cjsx');
var compileCoffee = require('broccoli-coffee');
var pickFiles = require('broccoli-funnel');
var mergeTrees = require('broccoli-merge-trees');
var browserify = require('broccoli-browserify');
var compileSass = require('broccoli-sass');
var autoprefixer = require('broccoli-autoprefixer');

var js = compileCJSX('src');
js = compileCoffee(js);
js = browserify(js, {
  entries: ['./index.js'],
  outputFile: './bundle.js'
});

js = pickFiles(js, {
  srcDir: '/',
  destDir: 'javascripts'
});

var css = compileSass(['sass'], '/index.sass', '/stylesheets/index.css');
css = autoprefixer(css, {cascade:true});

var index = pickFiles('public', {
  srcDir: '/',
  destDir: '/'
});

module.exports = mergeTrees([js, index, css]);
