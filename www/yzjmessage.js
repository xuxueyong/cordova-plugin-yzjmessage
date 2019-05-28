//var exec = require('cordova/exec');
//
//exports.coolMethod = function (arg0, success, error) {
//    exec(success, error, 'cordova-plugin-yzjmessage', 'coolMethod', [arg0]);
//};

var exec = require('cordova/exec');

exports.getExtra = function(success, error, userName) {
    exec(success, error, "CDVYZJMessage", "getExtra" , userName);
};

exports.getToken = function(success, error,codes) {
    exec(success, error, "CDVYZJMessage", "getToken",codes);
};

exports.allowPermission = function(success, error,codes) {
    exec(success, error, "CDVYZJMessage", "allowPermission",codes);
};
