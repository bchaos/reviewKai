#  cfcoptions : { "out": "../js/"   }
commonDB = require './commonDatabaseFiles'
module.exports =  (client,connection) -> 
    ### helper functions start ###
    calculateNewPros = (userId)->
        sql ='call calculateNewPros('+userId+')'
        connection.query sql,userId, (err, results) ->

    calculateNewPeers = (userId)->
        sql ='call calculateNewPeers('+userId+')'
        connection.query sql, (err, results) ->

    calculateProReviewForGame = (gameid, userid, callback)->
        sql = 'Select avg(rating) as rating , avg(enjoyment) as enjoyment ,  avg(unenjoyment) as unenjoyment , avg(difficulty) as difficulty, avg(length) as length  from ProReviewerLibrary prl ,userToProreviewer utp  where prl.id = utp.reviewer_id and utp.user_id='+userid+' and prl.game_id = '+gameid
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
        sql = 'Select review_link from ProReviewerLibrary prl ,userToProreviewer utp  where prl.id = utp.reviewer_id and utp.user_id='+userid+' and prl.game_id = '+gameid
        connection.query sql, [data.id], (err, result) ->
            callback result

    getOrCreateProReviewer= (data,callback)->
        sql ='Select count(*) as reviewerCount ,id from ProReviewers where name = "'+data.name+'"';
        connection.query sql, (err, result) ->
            firstresult= result[0]
            if firstresult.reviewerCount > 0 
                return callback firstresult.id
            else 
                sql = 'Insert into ProReviewers Set ?'
                connection.query sql,  data,  (err,result) ->    
                    gameid = result.insertId
                    return callback gameid


    getRecentReleases = (userid,client)->
        sql = 'select  count(*) as count from  userToReviewers  where user_id='+userid;
        connection.query sql,(err,result) ->
            if result[0].count > 0 
                sql = 'Select * from '
                sql +='(select  g.game_name , g.game_picture, g.id, g.giantBomb_id,g.releasedate, UNIX_TIMESTAMP(g.releasedate) as date   from  games g order by date desc) t1  '
                sql +=' join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and peer.rating != -1 and utr.user_id = '+userid+' group by peer.game_id ) t2 '
                sql +='on t1.id = t2.game_id left  join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id  ) t3 '
                sql +='on t3.game_id = t1.id'
                console.log sql
                connection.query sql, (err, result) ->
                    client.emit 'recentReleases', result
            else 
                client.emit 'noGames'

    getGurusGameForUser = (userid, client, platform) ->
        sql= 'call getGamesForUserOnplatform('+userid+',"'+platform+'" )'
        connection.query sql, (err, result) ->
            client.emit 'guruLibraryFound', result 

    getPeersGameForUser = (userid, client ,platform) ->
        sql= 'call getGamesForUserOnplatform('+userid+',"'+platform+'" )'
        connection.query sql,  (err, result) ->
            client.emit 'peerLibraryFound', result  

    getGamesForUserOnPlatform = (userid, client ,platform) ->

    getGamesForUser  = (username, localuserid  ,client)->
        library = {}
        sql = 'Select id,name,site,stream, picture from user where name = "'+username+'"'
        connection.query sql,  (err, result) ->
            if result.length <=0
                client.emit 'noLibraryFound'
            else
                userid = result[0].id
                user=result
                library.myLibrary = (userid ==localuserid)
                sql = 'Select * from '
                sql +='(select l.rating,l.added, g.id, l.description, g.giantBomb_id,g.releasedate, UNIX_TIMESTAMP(g.releasedate) as date  , g.game_name , g.game_picture from library l, games g where l.game_id = g.id and l.user_id ='+userid+' order by date desc ) t1 '
                sql +='left join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id  and peer.rating != -1 and utr.user_id = '+userid+' group by peer.game_id ) t2 '
                sql +='on t1.id = t2.game_id left join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' group by pro.game_id ) t3 '

                sql +='on t3.game_id = t1.id'
                console.log userid
                connection.query sql,  (err, result) ->
                    library.games=result
                    library.user=user
                    client.emit 'gameLibraryFound', library 

    addGameScore = (userid,gameid, bombid, callback) -> 
            sql = 'Select * from '
            sql +='(select g.id, g.giantBomb_id,g.releasedate   from  games g where g.giantBomb_id  = '+bombid+') t1 '
            sql +='left join (Select avg (peer.rating) as peerscore, peer.game_id from library peer, userToReviewers utr where  utr.reviewer_id = peer.user_id and peer.rating != -1 and utr.user_id = '+userid+'  and peer.game_id ='+gameid+' ) t2 '
            sql +='on t1.id = t2.game_id left join (Select avg (pro.rating) as guruscore, pro.game_id from ProReviewerLibrary pro, userToProreviewer utr where  utr.reviewer_id = pro.user_id and utr.user_id = '+userid+' and pro.game_id ='+gameid+' ) t3 '
            sql +='on t3.game_id = t1.id'
            connection.query sql, (err, result) ->
                console.log result
                callback result 

    updateGameList = (userid, gamelist, index,callback) ->
        length = gamelist.length
        if index < length
            game = gamelist[index]
            sql = 'select g.id, count(*) as count from  games g where g.giantBomb_id  ='+game.id;
            connection.query sql, (err, result) ->
                if result[0].count is 0 
                    updateGameList userid, gamelist, index+1,callback
                else 
                    addGameScore userid, result[0].id, game.id , (results)-> 
                        if results
                            game.details= results[0]
                            gamelist[index]=game
                        updateGameList userid, gamelist, index+1,callback
        else 
            callback gamelist
            
            
    ###helper functions end ###
    client.on 'GetLibrary', (username)->
       getGamesForUser username, client.userid,client
            
    client.on 'updateGameInLibrary', (data)->
        sql = ' Update library Set ? where id ='+data.id 
        connection.query sql,  data, (err,result) ->
            console.log 'game updated'
            getGamesForUser client.username, client.userid,client
    
    client.on 'GetGuruLibrary',      (platform)->
       getGurusGameForUser client.userid,client,platform
       
    client.on 'GetPeerLibrary', (platform)->
       getPeersGameForUser client.userid,client,platform

    isGameInLibrary = (data, callback)->
        sql ='select count(*) as count from library l where l. user_id ='+data.user_id+' and game_id = '+data.game_id
        connection.query sql,  data.userInfo, (err,results)->
            if results[0].count is 0
                callback false
            else
                callback true

    client.on 'AddNewGameToLibrary', (data)->
        commonDB.connection= connection
        commonDB.getOrCreateGame data.giantBombinfo, data.platforms, (gameid)-> 
            data.userInfo.game_id = gameid
            data.userInfo.user_id = client.userid
            isGameInLibrary data, (results)->
                if !results
                    sql = 'Insert into library Set ?'
                    connection.query sql,  data.userInfo, (err,results)->
                        calculateNewPeers data.userInfo.user_id
                        calculateNewPros data.userInfo.user_id
                        getGamesForUser client.username, client.userid, client

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

    client.on 'GetReviewForGame', (gameid) ->
        sql = 'Select * from games where id = ? '
        connection.query sql, [gameid], (err, result) ->
            result['peerReview'] = caluclatePeerReviewsForGame gameid
            result['proReview'] = calculateProReviewForGame gameid
            client.emit 'gameReview' ,result
    client.on 'deleteGame', (game)->
        sql ='delete from library where game_id ='+game.id+' and user_id='+client.userid
        connection.query sql, [gameid], (err, result) ->
            getGamesForUser client.username, client.userid,client
    client.on 'updateGame', (game) -> 

        sql = 'Update library set rating ='+parseInt game.rating+' and description = "' + game.description+'" where game_id ='+game.id+' and user_id='+client.userid
        console.log sql
        connection.query sql, (err, result) ->
            getGamesForUser client.username, client.userid,client
    
    client.on 'searchForGames', (games)->
        updateGameList  client.userid, games.list,0, (newlist)->
            client.emit 'searchfinished', newlist
            
    client.on 'getGuruDetails', (gameid)->
        sql ='Select g.game_name as name, pr.name as reviewerName, prl.true_score as score, prl.true_score_max as scoremax, prl.review_link as reviewlink from userToProreviewer utp, ProReviewerLibrary prl ,games g , ProReviewers pr where utp.user_id =' + client.userid+' and utp.reviewer_id = pr.id and g.id ='+gameid.gameid+' and prl.user_id = utp.reviewer_id and g.id = prl.game_id'
        connection.query sql, (err, result) ->
            client.emit 'guruDetailsFound', result

    client.on 'getPeerDetails', (gameid)->
        sql ='Select g.game_name as name, pr.name as reviewerName, prl.rating as score, prl.description as details from userToReviewers utp, library prl, games g , user pr where utp.user_id =' + client.userid+' and utp.reviewer_id = pr.id and g.id ='+gameid.gameid+' and prl.user_id = utp.reviewer_id and g.id = prl.game_id'
        connection.query sql, (err, result) ->
            console.log result
            client.emit 'peerDetailsFound', result
            
    getPros = ->
        sql= 'Select * from ProReviewers  where active = 1'
        connection.query sql, (err, result) ->
            console.log result
            client.emit 'ProreviewersFound', result
    client.on 'GetRecentGames', ()->
        getRecentReleases client.userid,client
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
    client.on 'GetListOfPlatforms' , (data)-> 
        sql ='Select display_name from platforms where active =1 group by display_name order by relevanceRanking' 
        connection.query sql, (err, result) ->
            client.emit 'platformsFound', result
    client.on 'UpdateUserLibraryInfo', (data)->
        sql ="Update user set site ='" +data.site+"', stream='"+data.stream+"' where id ="+client.userid
        connection.query sql, (err, result) ->
            
    client.on 'GetProreviewerLibrary', (data)->
        getProLibrary(data.id)
    client.on 'AddNewProGameToLibrary', (data)-> 
        commonDB.connection= connection
        commonDB.getOrCreateGame  data.giantBombinfo,data.platforms, (gameid)-> 
            data.userInfo.game_id = gameid
            sql =  'Insert into ProReviewerLibrary  Set ?'
            connection.query sql,  data.userInfo,  (err,results) ->
                
                getProLibrary(data.userInfo.user_id)
    client.on 'updateGamePlatforms', (data)->

         for platform in data.platforms
            commonDB.getOrCreatePlatform  platform.abbreviation,data.id, connection
            
    client.on 'AddGameandReviewerToLibrary',(data)->
        commonDB.connection= connection
        commonDB.getOrCreateGame  data.giantBombinfo,data.platforms, (gameid)-> 
            getOrCreateProReviewer data.pro ,(newuserid)->
                 data.userInfo.game_id = gameid
                 data.userInfo.user_id = newuserid
                 sql = 'Select count(*) as gamecount from ProReviewerLibrary where game_id = '+gameid+' and user_id='+newuserid   
                 connection.query sql, [data.giantBomb_id], (err, result) ->
                     client.emit 'finishedInsert'
                     firstresult= result[0]
                     if firstresult.gamecount is 0    
                        sql =  'Insert into ProReviewerLibrary  Set ?'
                        connection.query sql,  data.userInfo,  (err,results) ->
                            gameid = result.insertId
                            sql =  'call updateFakeUsers ('+gameid+','+gameid+')';
                            connection.query sql, (err,results) ->
    confidantList = ->
        sql = 'Select count(*) as friendsCount, u.name, u.site, u.picture, u.stream, u.id from user u, userToFriends uf where u.id = uf.friend_id and  uf.user_id ='+client.userid
        connection.query sql, (err, result) ->
            firstresult= result[0]
            if firstresult.friendsCount is 0
                client.emit 'noFriendsFound'
            else
                resultLength= result.length
                addConfidantCount result, 0, resultLength, (userlistWithConfidants)->
                    addGamesReviewed userlistWithConfidants, 0 , resultLength , (finalUserList)->
                        client.emit 'listOfFriends', finalUserList

    client.on 'GetConfidants', ()->
        confidantList()

    client.on 'AddConfidant', (data)->
        sql = 'Select Count(*) as doesRelationshipExist from userToFriends where user_id=' +client.userid+ ' and friend_id ='+data.friendid
        connection.query sql, (err, result) ->
            if result[0].doesRelationshipExist is 0
                sql= 'Insert into userToFriends (user_id, friend_id) values('+client.userid+','+data.friendid+')';
                console.log sql
                connection.query sql, (err, result) ->
                    confidantList()

    addConfidantCount= (userlist, index, length, callback)->
        if index is length
            callback userlist
        else
            sql ='Select Count(*) as confidantCount from userToFriends where friend_id='+userlist[index].id
            connection.query sql, (err, result) ->
                userlist[index].confidantCount= result[0].confidantCount
                addConfidantCount userlist, index+1, length, callback

    addGamesReviewed = (userlist, index, length, callback)->
        if index is length
            callback userlist
        else
            sql ='Select Count(*) as reviews from library where user_id='+userlist[index].id
            connection.query sql, (err, result) ->
                userlist[index].reviews= result[0].reviews
                addGamesReviewed userlist, index+1, length, callback

    client.on 'SearchForConfidants',(data)->
        sql ='Select count(*) as friendsCount, u.name, u.site, u.stream, u.picture, u.id from user u where u.name like '+ connection.escape('%'+data.search+'%')

        connection.query sql, (err, result) ->
            firstresult= result[0]
            if firstresult.friendsCount is 0
                client.emit 'noUsersFound'
            else
                resultLength= result.length
                addConfidantCount result, 0, resultLength, (userlistWithConfidants)->
                    addGamesReviewed userlistWithConfidants, 0 , resultLength , (finalUserList)->
                        client.emit 'listofPossibleConfidants', finalUserList
