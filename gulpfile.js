'use strict'

var gulp       = require('gulp')
  , path       = require('path')
  , purescript = require('gulp-purescript')
  , rimraf     = require('gulp-rimraf')
  ;

var paths =
    { src: 'src/**/*.purs'
    , bowerSrc: 'bower_components/purescript-*/src/**/*.purs'
    , dest: ''
    , docsDest: 'README.md'
    , testSrc: 'test/**/*.purs'
    , testDest: 'test/output'
    };

var options =
    { compiler: {}
    , docgen: {}
    , test:
        { output: 'test.js'
        , main: 'Test.System.Path.Unix'
        }
    };

var compile = function(compiler) {
    var psc = compiler(options.compiler);
    psc.on('error', function(e) {
        console.error(e.message);
        psc.end();
    });
    return gulp.src([paths.src, paths.bowerSrc])
        .pipe(psc)
        .pipe(gulp.dest(paths.dest));
};

gulp.task('make', function() {
    return compile(purescript.pscMake);
});

gulp.task('browser', function() {
    return compile(purescript.psc);
});

gulp.task('docs', function() {
    var docgen = purescript.docgen(options.docgen);
    docgen.on('error', function(e) {
        console.error(e.message);
        docgen.end();
    });
    return gulp.src(paths.src)
      .pipe(docgen)
      .pipe(gulp.dest(paths.docsDest));
});

gulp.task('watch-browser', function() {
    gulp.watch(paths.src, ['browser', 'docs']);
});

gulp.task('watch-make', function() {
    gulp.watch(paths.src, ['make', 'docs']);
});

gulp.task('watch-test', function() {
    gulp.watch([paths.src, paths.testSrc], ['test']);
});

gulp.task('clean-test', function() {
    return gulp.src(paths.testDest)
        .pipe(rimraf());
});

gulp.task('compile-test', ['clean-test'], function() {
    return gulp.src([paths.src, paths.bowerSrc, paths.testSrc])
        .pipe(purescript.psc(options.test))
        .pipe(gulp.dest(paths.testDest));
});

gulp.task('run-tests', ['compile-test'], function() {
    require(path.resolve(path.join(paths.testDest, options.test.output)));
});

gulp.task('test', ['compile-test', 'run-tests']);
gulp.task('default', ['make', 'docs']);
