connect = require('connect')
app = require('express')();
server = require('http').Server(app);
io = require('socket.io')(server)
crypto = require('crypto')
bcrypt = require('bcrypt')
fs= require('fs')
mysql = require 'mysql'
validator = require('validator')


__dirname=''
__userImagedir='../images/userimages/'
connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'root',
    password : 'propeller1',
    database : 'zf2reviewer'
})

server.listen 8080, ->
    console.log 'server activated'

app.get '/', (req,res) ->
    res.send '<h1>Hello world</h1>'

handler = (req,res) ->
    fs.readFile __dirname + '/index.html', (err,data)->
        if err
            res.writeHead 500
            res.end 'error loading index.html'
        else
            res.writeHead 200
            res.end data
addImageToFolder=(image)->
    

userRegister = require('./userRegistration');
gameLibraryMananger= require('./gameLibraryMananger');

io.on 'connection', (client) ->
    userRegister client,connection,bcrypt,crypto,validator 
    gameLibraryMananger client, connection    
   