'use strict';
var path = require("path");
var gulp = require("gulp");
var runSequence = require('run-sequence');
var shell = require('gulp-shell');
var connect = require('gulp-connect');
var open = require('open');


gulp.task('connect', function() {
  console.log('Starting BabylonHX');
  connect.server({
    root: ['bin_lime/html5/bin/'],
    port: 3000,
    livereload: true
  });
  open('http://localhost:3000');
});

gulp.task('restart', function() {
  console.log('reload BabylonHX');
  connect.reload();
});


var paths = {
    main: ["**/**.hx"]
};

gulp.task('default', function (callback) {
    gulp.start('connect');
    gulp.start('watch');

});

gulp.task('watch', function (callback) {
    gulp.watch(paths.main, ['buildpureJS', 'buildlime', 'restart']);
});


gulp.task('buildlime', shell.task([
    'lime build html5 -Dwebgl'
]));

gulp.task('buildpureJS', shell.task([
    'haxe build_js.hxml'
]));

gulp.task('install_dep', shell.task([
    'haxelib -notimeout install dox', 
    'haxelib -notimeout install openfl', 
    'haxelib -notimeout install swf', 
    'haxelib -notimeout install svg', 
    'haxelib -notimeout install actuate',
    'haxelib -notimeout install actuate', 
    'haxelib -notimeout git catamaranhx https://github.com/catamaranHX/catamaranHX_lib.git', 
    'haxelib -notimeout git snow https://github.com/underscorediscovery/snow.git', 
    'haxelib -notimeout git oimohx https://github.com/babylonhx/OimoHx.git', 
    'haxelib -notimeout git msgpack https://github.com/aaulia/msgpack-haxe.git', 
    'haxelib -notimeout git babylonhx https://github.com/babylonhx/BabylonHx_2.0.git'
]));

gulp.task('dox', shell.task([
    'lime build html5 -xml',
    'haxelib run dox -i bin_lime/html5/ -o api/'
]));