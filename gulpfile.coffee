gulp = require 'gulp'
jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
zip = require 'gulp-zip'
clean = require 'gulp-clean'

gulp.task 'jade', ->
  gulp.src './src/index.jade'
    .pipe jade
      pretty: true
    .pipe gulp.dest './'
  return

gulp.task 'coffee', ->
  gulp.src './src/coffee/*.coffee'
    .pipe coffee()
    .pipe gulp.dest './js/'
  return

gulp.task 'stylus', ->
  gulp.src './src/stylus/*.styl'
    .pipe stylus()
    .pipe gulp.dest './css/'
  return

gulp.task 'vendor', ->
  gulp.src './vendor/js/*'
    .pipe gulp.dest './js/'
  gulp.src './vendor/css/*'
    .pipe gulp.dest './css/'
  gulp.src './vendor/fonts/*'
    .pipe gulp.dest './fonts/'
  gulp.src './vendor/fonts/lato/*'
    .pipe gulp.dest './fonts/lato/'
  return

gulp.task 'watch', ->
  gulp.watch './src/index.jade', (e) ->
    gulp.run 'jade'
    return
  gulp.watch './src/coffee/*.coffee', (e) ->
    gulp.run 'coffee'
    return
  gulp.watch './src/stylus/*.styl', (e) ->
    gulp.run 'stylus'
    return
  return

gulp.task 'clean', ->
  gulp.src [
    './index.html'
    './js'
    './css'
    './fonts'
    './app.nw'
    ]
    .pipe clean()
  return

gulp.task 'build', ->
  gulp.run 'jade', 'coffee', 'stylus', 'vendor'
  return

gulp.task 'default', ->
  gulp.run 'jade', 'coffee', 'stylus', 'watch'
  return
