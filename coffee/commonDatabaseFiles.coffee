module.exports = {
    connection : ''
    ### common game adders using giantbomb info ###
    getOrCreateGame: (data,platforms, callback) -> 
        sql = 'Select count(*) as gamecount, id from games where giantBomb_id = '+data.giantBomb_id
        curConnection = @connection
        curPlatformCreator = @getOrCreatePlatform
        curConnection.query sql, (err, result) ->
            firstresult= result[0]
            if firstresult.gamecount > 0 
                return callback firstresult.id
            else 
                sql = 'Insert into games Set ?'
                curConnection.query sql,  data,  (err,result) ->
                    gameid = result.insertId
                    for platform in platforms
                        curPlatformCreator platform.abbreviation, gameid,curConnection
                    return callback gameid
                    
    getOrCreatePlatform: ( platform,gameid,aconnection) ->
        sql = 'Select count(*) as gamecount, id from platforms where active=1 and name = "'+platform+'"'
        aconnection.query sql, (err, result) ->
            firstresult= result[0]
            if firstresult.gamecount > 0 
                @addPlatformTogame firstresult.id, gameid,aconnection
            else 
                return 1
                
    addPlatformTogame :  (platformid, gameid ,aconnection)->
        gameinfo=  {game_id:gameid, platform_id:platformid }
        sql = 'insert into  gameOnplatform  Set ? '
        aconnection.query sql, gameinfo,  (err,result) ->
}
