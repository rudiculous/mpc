"use strict";

var pathM = require('path');
var rdclMiddleware = require('rdcl-middleware');

module.exports = function(grunt) {

    grunt.initConfig({
        'pkg': grunt.file.readJSON('package.json'),
    });

    grunt.task.loadTasks('./tasks');

    rdclMiddleware.assets.task(grunt, {
        'manifest': require('./app/assets/manifest'),
        'root': __dirname,
        'assetsDir': pathM.join(__dirname, 'static/assets'),
    });

    grunt.registerTask('default', ['assets', 'groc']);
};
