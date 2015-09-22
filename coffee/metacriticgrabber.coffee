#  cfcoptions : { "out": "../js/"   }
dataparserController =  (@$scope, @InfoRequestService,  @socket) ->
    $scope.getMetaData = ->
        InfoRequestService.getMetaData $scope.metacriticlink, (data)->
            metacriticdata = data
    addGameToLibrary = (index, length, gameData,  callback) ->
        if index is length
            callback()
        if not gameData[index].game 
            gameData[index].giantBombinfo = gameData[index-1].giantBombinfo
            socket.emit 'AddGameandReviewerToLibrary', gameData[index]
            addGameToLibrary(index+1, length,gameData,  callback)
        else
            InfoRequestService.searchForAGame gameData[index].game, (data)->
                if data.results.length is 0
                     addGameToLibrary(index+1, length,gameData,  callback)
                game= data.results[0]
                gameData[index].giantBombinfo={}
                gameData[index].giantBombinfo.giantBomb_id= game.id
                gameData[index].giantBombinfo.game_name= game.name
                gameData[index].platforms=game.platforms
                if game.image
                        gameData[index].giantBombinfo.game_picture= game.image.medium_url
                else 
                        gameData[index].giantBombinfo.game_picture=''
                gameData[index].giantBombinfo.description= game.deck
                gameData[index].giantBombinfo.releasedate= game.original_release_date
                socket.emit 'AddGameandReviewerToLibrary', gameData[index]
                addGameToLibrary(index+1, length,gameData,  callback)
    addPlatforms = (games, index,length,callback)->
        if index is length
            callback(true) 
        else 
            InfoRequestService.getDeckForGame games[index].bombid , (data)-> 
               newdata=data.results
               newdata.id = games[index].gameid
               socket.emit 'updateGamePlatforms', newdata 
               addPlatforms games,index+1,length,callback

    $scope.updateGamePlatforms =(files)->
        file = files[0]
        reader = new FileReader();
        reader.readAsText(file);
        reader.onload = (event)->
            csv= event.target.result
            curdata = $.csv.toObjects(csv)
            length =curdata.length 
            addPlatforms curdata, 0, length, ->
                alert finished

    $scope.uploadImage = (files)->
        file = files[0]
        reader = new FileReader();
        reader.readAsText(file);
        reader.onload = (event)->
            csv= event.target.result
            data = $.csv.toObjects(csv)
            OrganizedData=[]
            length =0
            for gamedata in data 
                length++
                organized={}
                organized.pro={}
                organized.pro.name=gamedata.name
                organized.pro.site_address= gamedata.Site_address
                organized.userInfo={}
                organized.game= gamedata.game
                organized.userInfo.review_link= gamedata.review_link
                organized.userInfo.true_score= gamedata.true_score
                if gamedata.true_score > 10
                    organized.userInfo.true_score_max =100
                    organized.userInfo.rating = gamedata.true_score /20
                else if gamedata.true_score > 5
                    organized.userInfo.true_score_max =10
                    organized.userInfo.rating = gamedata.true_score /2
                else
                    organized.userInfo.true_score_max =5
                    organized.userInfo.rating = gamedata.true_score  
                OrganizedData.push organized
            addGameToLibrary 0,length,OrganizedData,->
                alert('finished')
dataparserController
 .inject=['$scope', 'InfoRequestService',  'socket' ]


angular
    .module 'reviewApp',['ngAnimate', 'ngRoute','ngResource','ngSanitize', 'ionic']
    .service 'socket',($rootScope) ->
        socket = io.connect 'http://166.78.129.57:8080'
        {
            on: (eventname, callback) -> 
                socket.on eventname, ->
                    args=arguments
                    $rootScope.$apply ->
                        callback.apply socket,args
            emit:  (eventName, data, callback) ->
                socket.emit eventName, data, ->
                    args = arguments
                    $rootScope.$apply ->
                         if callback
                                callback.apply socket, args
        }
    .factory 'InfoRequestService', ['$http', ($http) -> 
        class InfoRequest
            searchForAGame: (game, callback)->
                GamesSearchUrl = 'http://www.giantbomb.com/api/search/?api_key=059d37ad5ca7f47e566180366eab2190e8c6da30&query='+game+'&field_list=name,image,id,deck,original_release_date,platforms,genres&resources=game&format=jsonp&json_callback=JSON_CALLBACK';
                $http.jsonp(GamesSearchUrl).success (data)->
                    callback data

            getDeckForGame:(gameid, callback)->
                GamesSearchUrl = 'http://www.giantbomb.com/api/game/'+gameid+'/?api_key=059d37ad5ca7f47e566180366eab2190e8c6da30&field_list=platforms,deck,genres,videos,original_release_date&format=jsonp&json_callback=JSON_CALLBACK';
                $http.jsonp(GamesSearchUrl).success (data)->
                    callback data
            getMetaData:(link, callback)->
                $http.get(link).success (data)->
                    callback data
        new InfoRequest()
    ]
    .controller 'dataparserController',dataparserController
