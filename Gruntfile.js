"use strict";

require('coffee-script/register');

var pathM = require('path');
var rdclMiddleware = require('rdcl-middleware');
var productionConfig = require('./settings/production');

module.exports = function(grunt) {

    grunt.initConfig({
        'pkg': grunt.file.readJSON('package.json'),
    });

    grunt.task.loadTasks('./tasks');

    rdclMiddleware.assets.task(grunt, {
        'manifest': require('./app/assets/manifest'),
        'root': __dirname,
        'assetsDir': pathM.join(__dirname, 'static/assets'),
        'staticBase': productionConfig.locals.staticBase + '/assets',
    });

    grunt.registerTask('default', ['assets', 'groc']);
};
