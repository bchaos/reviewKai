#  cfcoptions : { "out": "../js/"   }
module.exports =  (client,request) ->
    giantbombInfo = {}
    giantbombInfo.apikey ='api_key=059d37ad5ca7f47e566180366eab2190e8c6da30'
    giantbombInfo.baseurl ='http://www.giantbomb.com/api/'
    giantbombInfo.fiedList = '&field_list=name,image,id,deck,original_release_date,platforms,genres&resources=game&format=jsonp&json_callback=JSON_CALLBACK'
    giantbombInfo.searchPath='search/?'
    giantbombInfo.gamePath = 'game/'
    client.on 'findGamesInWiki',(game)->
        GameSearchURL = giantbombInfo.baseurl+giantbombInfo.searchPath+giantbombInfo.apikey+'&query='+game+giantbombInfo.fiedList;
        request GameSearchURL, (error, response, body) ->
            data=''
            if !error && response.statusCode is 200
                startPos = body.indexOf('({');
                endPos = body.indexOf('})');
                jsonString = body.substring(startPos+1, endPos+1);
                data = JSON.parse(jsonString);
                client.emit 'listOfGamesFromWiki', data
            else console.log error

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
