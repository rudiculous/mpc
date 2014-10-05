"use strict";

var path = require('path');

exports.environment = process.env.ENVIRONMENT || 'development';
exports.config = require('./' + exports.environment);
