connect = require('connect')
app = require('express')();
server = require('http').Server(app);
io = require('socket.io')(server)
crypto = require('crypto')
bcrypt = require('bcrypt')
salt = bcrypt.genSaltSync(10);
fs= require('fs')
mysql = require 'mysql'
validator = require('validator')


__dirname=''

connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'root',
    password : 'propeller1',
    database : 'zf2reviewer'
})

server.listen 8080, ->
    console.log 'server activated'

app.get '/', (req, res) ->
    res.send '<h1>Hello world</h1>'

handler = (req,res) ->
    fs.readFile __dirname + '/index.html', (err,data)->
        if err
            res.writeHead 500
            res.end 'error loading index.html'
        else
            res.writeHead 200
            res.end data
app.directive 'card-flipable', ->  
    restrict: 'E',
    templateUrl: 'card.html',

    
calculateNewPros = (userId)->
    sql ='call calculateNewPros('+userId+')'
    connection.query sql,userId, (err, results) ->

calculateNewPeers = (userId) -> 
    sql ='call calculateNewPeers('+userId+')'
    
    connection.query sql,  (err, results) ->
        console.log err
        console.log results                 

calculateProReviewForGame= (gameid, userid, callback)->
    sql = 'Select avg(rating) as rating , avg(enjoyment) as enjoyment ,  avg(unenjoyment) as unenjoyment , avg(difficulty) as difficulty ,  avg(length) as length  from ProReviewerLibrary prl ,userToProreviewer utp  where prl.id = utp.reviewer_id and utp.user_id='+userid+' and prl.game_id = '+gameid
    connection.query sql, [data.id], (err, result) ->
        callback result[0]
        
caluclatePeerReviewsForGame = (gameid,userid, callback)->
    sql = 'Select avg(rating) as rating , avg(enjoyment) as enjoyment ,  avg(unenjoyment) as unenjoyment , avg(difficulty) as difficulty ,  avg(length) as length  from library prl , userToReviewers utp  where prl.id = utp.reviewer_id and utp.user_id='+userid+' and prl.game_id = '+gameid
    connection.query sql, [data.id], (err, result) ->
        callback result[0]
        
calculateAllReviewForGame = (gameid,callback)->
    sql = 'Select avg(rating) as rating , avg(enjoyment) as enjoyment ,  avg(unenjoyment) as unenjoyment , avg(difficulty) as difficulty ,  avg(length) as length  from library l where l.game_id = '+gameid
    connection.query sql, [data.id], (err, result) ->
        callback result[0]

getReviewLinksForProReviewers = (gameid, callback) ->
    sql = 'Select review_link  from ProReviewerLibrary prl ,userToProreviewer utp  where prl.id = utp.reviewer_id and utp.user_id='+userid+' and prl.game_id = '+gameid
    connection.query sql, [data.id], (err, result) ->
        callback result

getOrCreateGame = (data, callback) -> 
    sql = 'Select count(*) as gamecount, id from games where giantBomb_id = ?'
    connection.query sql, [data.giantBomb_id], (err, result) ->
        firstresult= result[0]
        console.log data
        console.log firstresult
        if firstresult.gamecount > 0 
            return callback firstresult.id
        else 
            sql = 'Insert into games Set ?'
           
            connection.query sql,  data,  (err,result) ->
    
                gameid = result.insertId
                return callback gameid
getOrCreateProReviewer= (data,callback)->
    sql ='Select count(*) as reviewerCount ,id from ProReviewers where name = "'+data.name+'"';
    console.log data
    connection.query sql, (err, result) ->
        firstresult= result[0]
        if firstresult.reviewerCount > 0 
            return callback firstresult.id
        else 
            sql = 'Insert into ProReviewers Set ?'
            connection.query sql,  data,  (err,result) ->
    
                gameid = result.insertId
                return callback gameid
validateEmail=(email) ->
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email)
getRecentReleases = (userid, client)->
    sql = 'Select * from '
    sql +='(select  g.game_name , g.game_picture, g.id from  games g order by releasedate desc) t1  '
    sql +=' join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and utr.user_id = '+userid+' group by peer.game_id ) t2 '
    sql +='on t1.id = t2.game_id left  join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id ) t3 '
    sql +='on t3.game_id = t1.id left join (Select ((avg(pro.rating)*1.275 + avg(world.rating)*.725)/2)  as worldscore, world.game_id from library world, ProReviewerLibrary pro  where world.game_id = pro.game_id group by world.game_id ) t4 '
    sql +='on t4.game_id = t1.id'
    
    connection.query sql,  (err, result) ->
    	client.emit 'recentReleases', result 
        
getGurusGameForUser = ( userid, client) ->
    sql = 'Select * from '
    sql +='(select  g.game_name , g.game_picture, g.id from  games g order by releasedate desc) t1 '
    sql +=' join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and utr.user_id = '+userid+' group by peer.game_id ) t2 '
    sql +='on t1.id = t2.game_id  left join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id ) t3 '
    sql +='on t3.game_id = t1.id left join (Select ((avg(pro.rating)*1.275 + avg(world.rating)*.725)/2)  as worldscore, world.game_id from library world, ProReviewerLibrary pro  where world.game_id = pro.game_id group by world.game_id ) t4 '
    sql +='on t4.game_id = t1.id'
    
    connection.query sql,  (err, result) ->
    	client.emit 'guruLibraryFound', result 
    	
getPeersGameForUser = ( userid, client) ->
    sql = 'Select * from '
    sql +='(select  g.game_name , g.game_picture, g.id from  games g) t1 '
    sql +='join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and utr.user_id = '+userid+' group by peer.game_id ) t2 '
    sql +='on t1.id = t2.game_id left join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id ) t3 '
    sql +='on t3.game_id = t1.id left join (Select ((avg(pro.rating)*1.275 +  avg(world.rating)*.725)/2)  as worldscore, world.game_id from library world, ProReviewerLibrary pro  where world.game_id = pro.game_id group by world.game_id ) t4 '
    sql +='on t4.game_id = t1.id'
    
    connection.query sql,  (err, result) ->
    	client.emit 'peerLibraryFound', result    	
    	
getGamesForUser  = (userid ,client)->
    console.log userid
    sql = 'Select * from '
    sql +='(select l.rating,l.added, g.id, l.description , g.game_name , g.game_picture from library l, games g where l.game_id = g.id and l.user_id ='+userid+' ) t1 '
    sql +='left join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and utr.user_id = '+userid+' group by peer.game_id ) t2 '
    sql +='on t1.id = t2.game_id left join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id ) t3 '
    sql +='on t3.game_id = t1.id left join (Select ((avg(pro.rating)*1.275 +  avg(world.rating)*.725)/2)  as worldscore, world.game_id from library world, ProReviewerLibrary pro  where world.game_id = pro.game_id group by world.game_id ) t4 '
    sql +='on t4.game_id = t1.id'
    connection.query sql,  (err, result) ->
    	client.emit 'gameLibraryFound', result 

addGameScore = (userid, gameid, callback) -> 
    sql = 'Select * from '
    sql +='(select g.id from  games g where g.giantBomb_id  = '+gameid+') t1 '
    sql +='left join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and utr.user_id = '+userid+' group by peer.game_id ) t2 '
    sql +='on t1.id = t2.game_id left join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id ) t3 '
    sql +='on t3.game_id = t1.id left join (Select ((avg(pro.rating)*1.275 +  avg(world.rating)*.725)/2)  as worldscore, world.game_id from library world, ProReviewerLibrary pro  where world.game_id = pro.game_id group by world.game_id ) t4 '
    sql +='on t4.game_id = t1.id'
    connection.query sql, gameid, (err, result) ->
        console.log result
        callback result 
        
updateGameList = (userid, gamelist, index,callback) ->
    length = gamelist.length

    if index+1 < length
        game =gamelist[index]
        
        addGameScore userid, game.id , (results)-> 
            if results
                game.details= results[0]
                gamelist[index]=game
            updateGameList userid, gamelist, index+1,callback
    else 
        callback gamelist
io.on 'connection', (client) ->
    userid=0
    console.log 'userConnected'
        
    client.on 'SignUpUser', (data)->
        if not validator.isEmail(data.username)
            client.emit 'failureMessage', 'Not a valid email address'
        sql = 'Select Count(*) as userCount from user where username = ?'
        connection.query sql, [data.username], (err, result) ->
            if result[0].userCount >0 
                client.emit 'UserEmailAlreadyExists'
                console.log 'user exists '
            else 
                sql = 'Insert into user Set ?' 
                d = new Date()
                currentTime= d.getMilliseconds()
                newExpiration = currentTime + 7*86400000
                sessionKey=crypto.createHash('md5').update(currentTime+'salt').digest('hex')
                data.sessionKey= sessionKey
                data.expires=newExpiration
                data.password = bcrypt.hashSync(data.password, salt);
                connection.query sql,  data,  (err,result) ->
                    userid = result.insertId
                    accessList =  getAccessList false
                    client.emit 'userLoggedin', {sessionKey: sessionKey , location:'/home' , accessList:accessList}
                    
    client.on 'SignUpUserViaFacebook', (data)->
    updateExpirationDate =(  newExperationDate) ->
        sql = 'Update  user set expires ='+newExperationDate+' where  id ='+userid
        connection.query sql, (err,results) ->
            
    client.on 'logout'    ,(data)->
        updateExpirationDate 0
    getAccessList =(isadmin) ->
        accessList = [{name:'Dashboard', link:'dash'},{name:'Library', link:'library'},{name:'Recomendations', link:'guru'}]
       
        if isadmin      
            accessList.push {name:'Pros', link:'pros'}
        accessList
        
    client.on 'isUserLoggedin', (data)->
        d = new Date()
        currentTime= d.getMilliseconds()
        
        sql = 'Select * from  user where sessionkey	 = ? and expires >'+currentTime
        connection.query sql, [data.key], (err, result) ->
            if result[0]
                newExpiration = currentTime + 7*86400000
                userid= result[0].id
                accessList =  getAccessList result[0].isAdmin
                client.emit 'userLoggedin', {sessionKey: data.key, location:data.location, accessList:accessList}
                updateExpirationDate newExpiration
            else 
                client.emit 'failedToLogin', 0
            
        
    client.on 'GetLibrary' , ->
       getGamesForUser userid,client
            
    client.on 'updateGameInLibrary' , (data)->
        sql = ' Update library Set ? where id ='+data.id 
        connection.query sql,  data,  (err,result) ->
            console.log ' game updated'
            getGamesForUser userid,client
    client.on 'GetGuruLibrary' , ->
       getGurusGameForUser userid,client
       
    client.on 'GetPeerLibrary' , ->
       getPeersGameForUser userid,client

    client.on 'AddNewGameToLibrary' ,(data)->
        getOrCreateGame data.giantBombinfo, (gameid)-> 
            
            data.userInfo.game_id = gameid
            data.userInfo.user_id = userid
            sql =  ' Insert into library Set ?'
            console.log data.userInfo
            connection.query sql,  data.userInfo,  (err,results) ->
                console.log err
                calculateNewPeers data.userInfo.user_id
                calculateNewPros data.userInfo.user_id
                
                
              
                getGamesForUser userid,client
        
    client.on 'Login', (data)->
        sql = 'Select password, isAdmin,id from user where username ="'+data.username+'"'
        connection.query sql, (err, result) -> 
            if result.length>0
                bcrypt.compare data.password , result[0].password, (err,res)->
                    if res
                        userid=result[0].id
                        d = new Date()
                        currentTime= d.getMilliseconds()
                        newExpiration = currentTime + 7*86400000
                        sessionKey=crypto.createHash('md5').update(currentTime+'salt').digest('hex')
                        sql = 'Update user set sessionkey ="'+sessionKey+'", expires = '+newExpiration+' where  id ='+userid
                        accessList =  getAccessList result[0].isAdmin
                        client.emit 'userLoggedin', {sessionKey: sessionKey, location:'/home', accessList:accessList }
                        connection.query sql,  data.userInfo,  (err,results) ->
                          
                    else 
                        client.emit 'failureMessage', 'Username or Password incorrect' 
            else 
                client.emit 'failureMessage', 'User not found'
                
    client.on 'GetNewGameReviews', ->
        sql = 'Select * from games where 1 sort by added Desc limit 10'
        connection.query sql,  (err, result) ->
            games = []
            for res in result
                gameid=  res['id']
                res['peerReview'] = caluclatePeerReviewsForGame gameid
                res['proReview'] = calculateProReviewForGame gameid
                games.push res
            client.emit 'recentGames',games

    client.on 'GetReviewForGame' , (gameid) ->
        sql = 'Select * from games where id = ? '
        connection.query sql, [gameid], (err, result) ->
            result['peerReview'] = caluclatePeerReviewsForGame gameid
            result['proReview'] = calculateProReviewForGame gameid
            client.emit 'gameReview' ,result
        
    client.on 'updateGame', (game) -> 
        sql ='Update library set rating ='+game.rating+', description = "' + game.description+'" where id ='+game.game_id
        console.log sql
        connection.query sql, [gameid], (err, result) ->
            getGamesForUser userid,client
    
    client.on 'searchForGames' , (games)->
        updateGameList  userid, games.list,0, (newlist)->
            client.emit 'searchfinished', newlist
            
        
    client.on 'getGuruDetails' , (gameid)->
        sql ='Select g.game_name as name, pr.name as reviewerName, prl.true_score as score, prl.true_score_max as scoremax, prl.review_link as reviewlink from userToProreviewer utp, ProReviewerLibrary prl ,games g , ProReviewers pr where utp.user_id =' + userid+' and utp.reviewer_id = pr.id and g.id ='+gameid.gameid+' and prl.user_id = utp.reviewer_id and g.id = prl.game_id'
        connection.query sql,(err, result) ->
            client.emit 'guruDetailsFound', result

    client.on 'getPeerDetails', (gameid)->
        sql ='Select g.game_name as name, pr.name as reviewerName, prl.rating as score, prl.description as details from userToReviewers utp, library prl, games g , user pr where utp.user_id =' + userid+' and utp.reviewer_id = pr.id and g.id ='+gameid.gameid+' and prl.user_id = utp.reviewer_id and g.id = prl.game_id'
   
        connection.query sql,(err, result) ->
            console.log result
            client.emit 'peerDetailsFound', result
            
    getPros = ->
        sql= 'Select * from ProReviewers  where active = 1'
        connection.query sql,(err, result) ->
            console.log result
            client.emit 'ProreviewersFound', result
    client.on 'GetRecentGames', ()->
        getRecentReleases userid,client
    client.on 'GetProreviewers' ,(data)->
        getPros()
        
    client.on 'addPro', (data)->
        sql = 'Insert into ProReviewers Set ?'
        connection.query sql,  data, (err,result) ->
            getPros()
    client.on 'ProReviewers', (data)->
        sql ='Update library set site_address ='+data.site_address+', name = "' + data.name+'" where id ='+data.id
    
        connection.query sql, [gameid], (err, result) ->
               getPros()
    getProLibrary = (id)-> 
        sql= 'Select * from  ProReviewerLibrary pr, games g where g.id=pr.game_id and pr.user_id ='+id
        console.log sql
        connection.query sql,(err, result) ->
            
            client.emit 'ProLibrarysFound', result
    client.on 'GetProreviewerLibrary', (data)->
        getProLibrary(data.id)
    client.on 'AddNewProGameToLibrary', (data)-> 
        getOrCreateGame data.giantBombinfo, (gameid)-> 
            data.userInfo.game_id = gameid
            sql =  'Insert into ProReviewerLibrary  Set ?'
            connection.query sql,  data.userInfo,  (err,results) ->
                
                getProLibrary(data.userInfo.user_id)
    client.on 'AddGameandReviewerToLibrary',(data)->
         getOrCreateGame data.giantBombinfo, (gameid)-> 
            getOrCreateProReviewer data.pro ,(newuserid)->
                 data.userInfo.game_id = gameid
                 data.userInfo.user_id = newuserid
                 sql = 'Select count(*) as gamecount from ProReviewerLibrary where game_id = '+gameid+' and user_id='+newuserid   
                 connection.query sql, [data.giantBomb_id], (err, result) ->
                     firstresult= result[0]
                     if firstresult.gamecount is 0    
                        sql =  'Insert into ProReviewerLibrary  Set ?'
                        connection.query sql,  data.userInfo,  (err,results) ->