var gulp = require('gulp');

const { series, parallel } = require('gulp');
var del = require('del');
var uglify = require('gulp-uglify');
var cleanCSS = require('gulp-clean-css');
var merge = require('merge-stream');
var concat = require('gulp-concat');
var replace = require('gulp-replace');

var galette = {
    'modules': './node_modules/',
    'public': './galette/webroot/assets/'
};

var main_styles = [
    './galette/webroot/themes/default/galette.css',
    './node_modules/@fortawesome/fontawesome-free/css/all.css',
    './node_modules/jquery-ui-dist/jquery-ui.css',
    './galette/webroot/themes/default/jquery-ui/jquery-ui-1.12.1.custom.css',
    './node_modules/selectize/dist/css/selectize.default.css',
];

var main_scripts = [
    './node_modules/jquery/dist/jquery.js',
    './node_modules/jquery-ui-dist/jquery-ui.js',
    './node_modules/jquery.cookie/jquery.cookie.js',
    './node_modules/microplugin/src/microplugin.js',
    './node_modules/sifter/sifter.js',
    './node_modules/selectize/dist/js/selectize.min.js',
    './galette/webroot/js/jquery/jquery.bgFade.js',
    './galette/webroot/js/common.js',
];

var main_assets = [
    {
        'src': './node_modules/@fortawesome/fontawesome-free/webfonts/*',
        'dest': '/webfonts/'
    }, {
        'src': './node_modules/jquery-ui-dist/images/*',
        'dest': '/images/'
    }, {
        'src': './galette/webroot/themes/default/jquery-ui/images/*',
        'dest': '/images/'
    }, {
        'src': './node_modules/farbstastic/*.png',
        'dest': '/images/'
    }
];

const clean = function(cb) {
  del([galette.public]);
  cb();
};

function styles() {
  var _dir = galette.public + '/css/';

  main = gulp.src(main_styles)
    .pipe(replace('jquery-ui/images/', '../images/'))
    .pipe(replace('("images/ui', '("../images/ui')) //
    .pipe(replace('url(images/', 'url(../../themes/default/images/'))
    //.pipe(cleanCSS())
    .pipe(concat('galette-main.bundle.min.css'))
    .pipe(gulp.dest(_dir));

  jqplot = gulp.src('./galette/webroot/js/jquery/jqplot-1.0.8r1250/jquery.jqplot.css')
    .pipe(concat('galette-jqplot.bundle.min.css'))
    .pipe(cleanCSS())
    .pipe(gulp.dest(_dir));

  picker = gulp.src('./node_modules/farbstastic/farbtastic.css')
    .pipe(replace('url(', 'url(../images/'))
    .pipe(cleanCSS())
    .pipe(gulp.dest(_dir))

  return merge(main, jqplot, picker);
};

function scripts() {
  var _dir = galette.public + '/js/';

  main = gulp.src(main_scripts)
    .pipe(concat('galette-main.bundle.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest(_dir));

  jstree = gulp.src('./node_modules/jstree/dist/jstree.min.js')
    .pipe(uglify())
    .pipe(gulp.dest(_dir));

  //use local lib, npm one is missing plugins :/
  jqplot = gulp.src([
        './galette/webroot/js/jquery/jqplot-1.0.8r1250/jquery.jqplot.min.js',
        './galette/webroot/js/jquery/jqplot-1.0.8r1250/plugins/jqplot.barRenderer.min.js',
        './galette/webroot/js/jquery/jqplot-1.0.8r1250/plugins/jqplot.categoryAxisRenderer.min.js',
        './galette/webroot/js/jquery/jqplot-1.0.8r1250/plugins/jqplot.pieRenderer.min.js',
        './galette/webroot/js/jquery/jqplot-1.0.8r1250/plugins/jqplot.pointLabels.min.js',
  ])
    .pipe(concat('galette-jqplot.bundle.min.js'))
    .pipe(uglify())
    .pipe(gulp.dest(_dir));

  picker = gulp.src('./node_modules/farbstastic/farbtastic.js')
    .pipe(uglify())
    .pipe(gulp.dest(_dir));

  return merge(main, jstree, jqplot, picker);
};

function assets() {
    main = main_assets.map(function (asset) {
        return gulp.src(asset.src)
            .pipe(gulp.dest(galette.public + asset.dest));
        }
    );

    return merge(main);
};

exports.clean = clean;

exports.styles = styles;
exports.scripts = scripts;
exports.assets = assets;

exports.build = series(styles, scripts, assets);
exports.default = exports.build;
