# CustomSqliteDbPlugin


CustomSqlitePlugin has following functions and can be used as follows:
1) Open Database
2) Execute SQL Statement - Create, insert, delete, update
3) Close DB
4) Destroy DB


1) To open the database or create a database with path

if path = "/Users/documents/Sqlite/SqlitePlugin.sqlite", then use the following:

cordova.plugins.openDatabase(path, function(success) {
  //Success code
}, function(error) {
  // Error code
});


2) To query the sqlite db using SQL statement - create, insert, delete, update statements

sqlStataement = "CREATE TABLE IF NOT EXISTS USER(id INTEGER PRIMARY KEY NOT NULL, email TEXT UNIQUE NOT NULL, fullName TEXT NOT NULL);"

cordova.plugins.executeSQLStatement(sqlStataement, function(success) {
  //Success code
}, function(error) {
  // Error code
});


3) To close the DB, following is the code.

cordova.plugins.closeDB(sqlStataement, function(success) {
  //Success code
}, function(error) {
  // Error code
})


4) When database to be destroyed

if path = "/Users/documents/Sqlite/SqlitePlugin.sqlite", then use the following

cordova.plugins.destroyDatabase(path, function(success) {
  //Success code
}, function(error) {
  // Error code
})
