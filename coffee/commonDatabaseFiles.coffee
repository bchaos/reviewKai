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
                        curPlatformCreator platform.abbreviation, gameid
                    return callback gameid
                    
    getOrCreatePlatform: ( platform,gameid) -> 
        sql = 'Select count(*) as gamecount, id from platforms where active=1 and name = "'+platform+'"'
        @connection.query sql, (err, result) ->
            firstresult= result[0]
            if firstresult.gamecount > 0 
                @addPlatformTogame firstresult.id, gameid
            else 
                return 1
                
    addPlatformTogame :  (platformid, gameid)->
        gameinfo=  {game_id:gameid, platform_id:platformid }
        sql = 'insert into  gameOnplatform  Set ? '
        @connection.query sql, gameinfo,  (err,result) ->
}
