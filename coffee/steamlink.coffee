#  cfcoptions : { "out": "../js/"   }

module.exports =  (client,connection,request) -> 
    SteamInfo = {
        key : 'key=33701385AB8FAE0087AD343546590367'
        baseurl : 'http://api.steampowered.com'
        ownedPath: "/IPlayerService/GetOwnedGames/v0001/?"
        vanityPath:"/ISteamUser/ResolveVanityURL/v0001/?" 
        gameIncludes :"&include_appinfo=1"
        format :"&format=json"
    }
    isSteamAccountLinked = ()->
        sql = 'Select Count(*) as userCount , steamID from user where steamID != null id = ' + client.userid
        connection.query sql, (err, result) ->
            if result[0].userCount is 0 
                return false
            else
                return result[0].steamID
    getSteamAccountInfo =(vanityName ,callback)->
        steamid = isSteamAccountLinked()
        if not steamid
            vanity = '&vanityurl='+vanityName
            getSteamIdURL=SteamInfo.baseurl+SteamInfo.vanityPath+SteamInfo.key+vanity
            request getSteamIdURL, (error, response, body) ->
                if !error && response.statusCode is 200
                    data = JSON.parse jsonString
                    callback data.response.steamid
        else     
            callback steamid
            
    client.on 'importGamesFromSteam' , (data)->
        getSteamAccountInfo data.name, (returnedID)  ->
            steamid ='&steamid='+returnedID
            steamImportUrl = SteamInfo.baseurl+SteamInfo.ownedPath+SteamInfo.key+steamid+SteamInfo.gamesInclues +SteamInfo.format
            request steamImportUrl, (error, response, body) ->
                if !error && response.statusCode is 200
                    data = JSON.parse jsonString
                    for game in data.response.games
                        if game.playtime_forever > 10 
                            ###add game to user library###
                            
                    client.emit 'steamGamesToAdd', data
                else 
                    client.emit 'steamImportError', error