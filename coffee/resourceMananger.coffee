#  cfcoptions : { "out": "../js/"   }
commonDB = require './commonDatabaseFiles'
module.exports = (client,connection) ->
    doesResourceExist =(resource, callback)->
        sql = 'Select count(*), id from where link ="'+ resource.link+'" and game_id = '+resource.gameid
        connection.query sql, (err,results)->
            if results[0].count is 0
                callback false
            else
                callback results[0].id
    addResourceToClientLibrary = (resourceid)->
        data={user_id:client.userid, resource_id :resourceid}
        sql = 'insert into userToResource SET ?'
        connection.query sql,  data.userInfo, (err,results)->
            client.emit 'ResourceAdded'

    client.on 'addResource',(resourceInfo)->
        doesResourceExist  resourceInfo, (exists)->
            if exists
                addResourceToClientLibrary exists
            else
                sql= 'insert into resources SET ?'
                connection.query sql,  data.userInfo, (err,results)->
                    resourceid = result.insertId
                    addResourceToClientLibrary resourceid
    getResource = (game, user, callback)->
        sql ='Select * from userToResource utr, resources r where utr.user_id = '+user+' and utr.resource_id= r.id and r.game_id='+game
        connection.query sql, (err,results)->
            callback results

    client.on 'getMyResources', (game)->
        getResource game.id, client.userid, (results)->
            client.emit 'yourResourcesForThisGame', results

    client.on 'getResourceFromUserToGame', (game)->
        getResource game.id,game.userid, (results)->
             client.emit 'thisUserResources', results

    client.on 'getRecommendedResources', (game)->
        sql= 'Select r.link, r.name, r.description, u.username from resources r , user u, userToResources utr, userToReviewers utp where utp.user_id  =' + client.userid+' and utp.reviewer_id = utr.user_id and u.id = utp.reviewer_id and r.id = utr.resource_id'
        connection.query sql,  (err,results)->
            client.emit 'recommendedReources', results

    client.on 'removeResource', (resourceInfo)->
        sql ='delete from rescourcesr where r.resource_id ='+resouceInfo.id+' and user_id =' +client.user_id
        connection.query sql,  (err,results)->
             getResource resouceInfo.gameid,client.userid , (results)->
                client.emit 'yourResourcesForThisGame', results
