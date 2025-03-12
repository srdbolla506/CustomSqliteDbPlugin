var exec = require('cordova/exec');

exports.openDatabase = function (arg0, success, error) {
    exec(success, error, 'SqlitePlugin', 'openDB', [arg0]);
};

exports.closeDB = function (success, error) {
    exec(success, error, 'SqlitePlugin', 'closeDB', []);
};

exports.executeSQLStatement = function (arg0, success, error) {
    exec(success, error, 'SqlitePlugin', 'executeSQLStatement', [arg0]);
};

exports.insertIntoTable = function (arg0, success, error) {
    exec(success, error, 'SqlitePlugin', 'insertIntoTable', [arg0]);
};

exports.destroyDatabase = function (arg0, success, error) {
	exec(success, error, 'SqlitePlugin', 'destroyDatabase', [arg0]);
};
