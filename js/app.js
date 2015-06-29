(function() {
  var addImageToFolder, app, bcrypt, connect, connection, crypto, fs, gameLibraryMananger, giantBombMananger, handler, io, mysql, request, server, userRegister, validator, __dirname, __userImagedir;

  connect = require('connect');

  app = require('express')();

  server = require('http').Server(app);

  io = require('socket.io')(server);

  crypto = require('crypto');

  bcrypt = require('bcrypt');

  fs = require('fs');

  request = require('request');

  mysql = require('mysql');

  validator = require('validator');

  __dirname = '';

  __userImagedir = '../images/userimages/';

  connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'propeller1',
    database: 'zf2reviewer'
  });

  server.listen(8080, function() {
    return console.log('server activated');
  });

  app.get('/', function(req, res) {
    return res.send('<h1>Hello world</h1>');
  });

  handler = function(req, res) {
    return fs.readFile(__dirname + '/index.html', function(err, data) {
      if (err) {
        res.writeHead(500);
        return res.end('error loading index.html');
      } else {
        res.writeHead(200);
        return res.end(data);
      }
    });
  };

  addImageToFolder = function(image) {

    /* add images here */
  };

  userRegister = require('./userRegistration');

  gameLibraryMananger = require('./gameLibraryMananger');

  giantBombMananger = require('./giantbomb');

  io.on('connection', function(client) {
    userRegister(client, connection, bcrypt, crypto, validator);
    gameLibraryMananger(client, connection);
    return giantBombMananger(client, request, connection);
  });

}).call(this);
