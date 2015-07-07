#  cfcoptions : { "out": "../js/"   }
commonDB = require './commonDatabaseFiles'
module.exports =  (client,request,connection) ->
    giantbombInfo = {}
    giantbombInfo.apikey ='api_key=059d37ad5ca7f47e566180366eab2190e8c6da30'
    giantbombInfo.baseurl ='http://www.giantbomb.com/api/'
    giantbombInfo.fiedList = '&field_list=name,image,id,deck,original_release_date,platforms,genres&resources=game&format=jsonp&json_callback=JSON_CALLBACK'
    giantbombInfo.searchPath='search/?'
    giantbombInfo.gamePath = 'game/'
    client.on 'findGamesInWiki',(game)->
        getGameInfo game ,(data)->
            client.emit 'listOfGamesFromWiki', data
    
    client.on 'getGameInfoFromWiki', (gameid)->
        GameSearchURL = giantbombInfo.baseurl+giantbombInfo.gamePath+gameid+'/?'+giantbombInfo.apikey+giantbombInfo.fiedList;
        request GameSearchURL, (error, response, body) ->
            if !error && response.statusCode is 200
                startPos = body.indexOf('({');
                endPos = body.indexOf('})');
                jsonString = body.substring(startPos+1, endPos+1);
                data = JSON.parse(jsonString);
                client.emit 'gameInfoForGameFromWiki', data
            else console.log error
    getGameInfo = (game, callback)->
        GameSearchURL = giantbombInfo.baseurl+giantbombInfo.searchPath+giantbombInfo.apikey+'&query='+game+giantbombInfo.fiedList;
        request GameSearchURL, (error, response, body) ->
            data=''
            if !error && response.statusCode is 200
                startPos = body.indexOf('({');
                endPos = body.indexOf('})');
                jsonString = body.substring(startPos+1, endPos+1);
                data = JSON.parse(jsonString);
                callback data
            else console.log error
    
    ### Steam ###
    SteamInfo = {
        key : 'key=33701385AB8FAE0087AD343546590367'
        baseurl : 'http://api.steampowered.com'
        ownedPath: "/IPlayerService/GetOwnedGames/v0001/?"
        vanityPath:"/ISteamUser/ResolveVanityURL/v0001/?" 
        gameIncludes :"&include_appinfo=1"
        format :"&format=json"
    }
    isSteamAccountLinked = (callback)->
        sql = 'Select Count(*) as userCount , steamID from user where steamID != 0 and steamID != -1  and id = ' + client.userid
        
        connection.query sql, (err, result) ->
            if result[0].userCount is 0 
                callback false
            else
                callback result[0].steamID
    getSteamAccountInfo =(vanityName ,callback)->
         isSteamAccountLinked (returnedid) -> 
            steamid =returnedid
           
            if  steamid is false
                vanity = '&vanityurl='+vanityName
                getSteamIdURL=SteamInfo.baseurl+SteamInfo.vanityPath+SteamInfo.key+vanity
                console.log getSteamIdURL
                request getSteamIdURL, (error, response, body) ->
                    if !error && response.statusCode is 200
                        data = JSON.parse body
                        console.log data
                        if data.response.success is 1  
                            callback data.response.steamid
                        else 
                            callback false
            else     
                callback steamid
    addSteamIdToGame = (gameid, steamid) ->
        sql = 'update games set steam_id ='+steamid+' where id ='+gameid
        connection.query sql, (err,results)->
            
    getGameWithSteamId= (steamid,callback)->
        sql ='select count(*) as count ,id  from games g where g.steam_id = '+steamid
        connection.query sql, (err,results)->
            if results[0].count is 0
                callback false
            else
                callback  results[0].id
    doesUserHaveGame = (gameid, callback)->
        sql =  'Select count(*) as count from library l, games g where l.user_id ='+client.userid+' and g.giantBomb_id ='+gameid+' and g.id = l.game_id'
        connection.query sql, (err,results)->
            callback results[0]

    getGiantBombVersionOfGames = (games,index, length, callback) ->
        if index is length 
            callback(games)
        else
            if games[index].playtime_forever > 20
                getGameWithSteamId games[index].appid ,(steamToGameid)->
                    newgame={}
                    newgame.userInfo.rating=-1
                    newgame.userInfo.enjoyment=3
                    newgame.userInfo.length=3
                    newgame.userInfo.unenjoyment=3
                    newgame.userInfo.difficulty=3
                    newgame.userInfo.user_id = client.userid
                    if steamToGameid is false
                        getGameInfo games[index].name,(gamelist)->
                            game = gamelist.results[0]
                            console.log gamelist
                            console.log game
                            newgame.userInfo = {}
                            newgame.giantBombinfo={}
                            newgame.giantBombinfo.giantBomb_id= game.id
                            newgame.giantBombinfo.game_name= game.name
                            newgame.giantBombinfo.game_picture= game.image.medium_url
                            newgame.giantBombinfo.description= game.deck
                            commonDB.connection = connection
                            doesUserHaveGame gameid, (count)->
                                if count is 0
                                    getGiantBombVersionOfGames games, index+1, length, callback
                                else
                                    commonDB.getOrCreateGame newgame.giantBombinfo , game.platforms, (gameid)->
                                        newgame.userInfo.game_id = gameid
                                        addSteamIdToGame gameid, games[index].appid
                                        sql = 'Insert into library Set ?'
                                        connection.query sql, newgame.userInfo, (err,results)->
                                            getGiantBombVersionOfGames games, index+1, length, callback
                    else
                        doesUserHaveGame steamToGameid, (count)->
                            if count is 0
                                getGiantBombVersionOfGames games, index+1, length, callback
                            else
                                newgame.userInfo.game_id = steamToGameid
                                sql = 'Insert into library Set ?'
                                connection.query sql, newgame.userInfo, (err,results)->
                                    getGiantBombVersionOfGames games, index+1, length, callback
            else 
                getGiantBombVersionOfGames games, index+1, length, callback
                
    client.on 'importGamesFromSteam', (data)->
        getSteamAccountInfo data.name, (returnedID)->
            steamid ='&steamid='+returnedID
            if returnedID is false
                client.emit 'vanityNameNotFound'
            else    
                steamImportUrl = SteamInfo.baseurl+SteamInfo.ownedPath+SteamInfo.key+steamid+SteamInfo.gameIncludes+SteamInfo.format
                console.log steamImportUrl
                request steamImportUrl, (error, response, body) ->
                    if !error && response.statusCode is 200
                        data = JSON.parse body
                        commonDB.connection = connection
                        getGiantBombVersionOfGames data.response.games, 0,  data.response.games.length, (games)->
                            client.emit 'steamGamesToAdd', games
                    else 
                        client.emit 'steamImportError', error
                        
                        
    ### XBOX ###

    xbox = {
        key:'b5cfd5d7019993e435b7b125c4276bfb4f0a8c62'
        profileID: '2533274828210569'
    }
