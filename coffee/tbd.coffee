#  cfcoptions : { "out": "../js/"   }
app = angular.module 'reviewApp',['ngAnimate', 'ngRoute','ngResource','ngSanitize', 'ionic'],
 ($routeProvider, $locationProvider)->
            $routeProvider.when '/library', {
                templateUrl: 'views/library.html'
                controller: 'libraryController'
            }
            $routeProvider.when '/guru', {
                templateUrl: 'views/library.html'
                controller: 'guruController'
            }
            $routeProvider.when '/', {
                templateUrl: 'views/home.html'
                controller: 'homeController'
            }
            $routeProvider.when '/home', {
                templateUrl: 'views/home.html'
                controller: 'homeController'
            }
            $routeProvider.when '/faqs', {
                templateUrl: 'views/faqs.html'
               
            }
            $routeProvider.when '/contact', {
                templateUrl: 'views/contact.html'
                controller: 'genericController'
               
            }

            $routeProvider.when '/confidants', {
                templateUrl: 'views/confidants.html'
                controller: 'confidantController'

            }

            $routeProvider.when '/PrivacyPolicy', {
                templateUrl: 'views/PrivacyPolicy.html'
                controller: 'genericController'
            }
        
            $routeProvider.when '/recommendations', {
                templateUrl: 'views/recommendations.html'
                controller: 'recommendationController'
            }
            $routeProvider.when '/blog', {
                templateUrl: 'views/blog.html'
               
            }
            $routeProvider.when '/peer', {
                templateUrl: 'views/library.html'
                controller: 'peerController'
            }

            $routeProvider.when '/dashboard', {
                templateUrl: 'views/dashboard.html'
                controller: 'dashboardController'
            }
    
            $routeProvider.when '/settings', {
                templateUrl: 'views/settings.html'
                controller: 's'
            }

            $routeProvider.when '/search', {
                templateUrl: 'views/search.html'
                controller: 'searchController'
            }

        
            $routeProvider.otherwise {
                templateUrl: 'views/library.html'
                controller: 'libraryController'
            }

app.directive 'platfromcard', ->  
    restrict: 'E',
    templateUrl: 'views/platformcard.html',
app.directive 'confidantcard', ->
    restrict: 'E',
    templateUrl: 'views/confidantCard.html',
app.directive 'card', ->  
    restrict: 'E',
    templateUrl: 'views/card.html',
app.directive 'searching', ->  
    restrict: 'E',
    templateUrl: 'views/searching.html',
app.directive 'librarycard', ->  
    restrict: 'E',
    templateUrl: 'views/librarycard.html'
app.directive 'searchcard', ->  
    restrict: 'E',
    templateUrl: 'views/searchcard.html' 
app.directive 'steamtransfer', ->
    restrict: 'E',
    templateUrl: 'views/steamTransfer.html'
app.config ($httpProvider) -> 
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common['X-Requested-With'];

app.service 'socket',($rootScope) ->
    socket = io.connect 'http://ReviewKai.com:8080'
    {
        on: (eventname, callback) -> 
            socket.on eventname, ->
                args=arguments
                $rootScope.$apply ->
                    callback.apply socket,args
        emit: (eventName, data, callback) ->
            socket.emit eventName, data, ->
                args = arguments
                $rootScope.$apply ->
                     if callback
                        callback.apply socket, args
    }

app.filter('myLimitTo', [->
     (obj, limit,offset)->
        keys = Object.keys(obj);
        if(keys.length < 1)
            return [];
        ret = new Object
        count = 0
        startingpoint=0
        angular.forEach keys, (key, arrayIndex)->
           if(count >= limit)
                return false;
            if startingpoint>=offset
                ret[key] = obj[key];
                count++;
            else 
                startingpoint>=offset++
        return ret;
])

isloggedin = (socket, location)-> 
    if window.localStorage.sessionkey
        socket.emit 'isUserLoggedin' , {key:window.localStorage.sessionkey, location:location}
    
        
createGameDetailViewer= ( $ionicModal, $scope, socket) ->
            $scope.newOffset = 0;   
            if $scope.myLibrary && $scope.localLibrary
                $scope.itemsPerPage = 11;
            else 
                $scope.itemsPerPage = 12;
            
            $scope.currentPage = 0;
            $scope.onCurrentPage =(num)->
                if num is $scope.currentPage
                    return 'button-balanced'
                return 'button-stable';
        
            $scope.setUpPages =()->
                pagecount = Math.ceil($scope.games.length/$scope.itemsPerPage); 
                $scope.maxPages=pagecount
                $scope.pages=[]
                createNumberList()
              
            createNumberList = ->
                lastPage = $scope.maxPages
                firstPage=0;
                $scope.pages=[]
                length =9 
                hasElispes=false;
                if $scope.maxPages > length+1 && $scope.currentPage+4 >=   $scope.maxPages-1
                    firstPage=$scope.maxPages-length
                    lastPage =$scope.maxPages
                    
                else if $scope.maxPages > length+1 && $scope.currentPage >= length-1
                    firstPage=$scope.currentPage-4
                    lastPage= $scope.currentPage+4
                
                else if $scope.maxPages > length+1
                    lastPage= length
                
                if  firstPage > 0 
                    $scope.pages.push {number:0, startingPoint:0}
                    $scope.pages.push {elispe:true, number:false}
                for i in [firstPage...lastPage]
                    $scope.pages.push {number:i, startingPoint:i*$scope.itemsPerPage}
                
                if lastPage < $scope.maxPages-1
                    $scope.pages.push {elispe:true, number:false}
                    $scope.pages.push {number:$scope.maxPages-1, startingPoint:($scope.maxPages-1)*$scope.itemsPerPage}
                
            $scope.setPage = (num)->
                if num>=0 and num<$scope.maxPages
                    $scope.currentPage=num
                    $scope.newOffset= $scope.currentPage*$scope.itemsPerPage
                    createNumberList()
                    
            $scope.gameDetails={}
            $scope.sort = '-releasedate'
            $scope.convertMyRating= (score)->
                 if score >10
                    score =score/20
                 if score >5
                    score =score/2
                 saying = switch
                    when score is 1 then 'This game is  unplayable'
                    when score is 2 then 'Bad but playable in a pinch'
                    when score is 3 then 'A fairly average game'
                    when score is 4 then 'Good game with some minor flaws'
                    else 'A nearly flawless gameplay experience'
            $scope.convertAverageLibraryClass=(score,rating,islibrary)->   
                if not islibrary
                    return  $scope.convertAverageClass score
                else
                    return  $scope.convertAverageClass rating
            $scope.convertAverageClass =(score)->
                if not score || score is 0 || score is -1
                    return 'unknown'
                saying = switch
                    when score < 1.5 then 'negative'
                    when score < 2.5 then 'negative'
                    when score < 3.5 then 'ok'
                    when score < 4   then 'ok'
                    when score < 4.5 then 'postive'
                    else 'postive'
            $scope.convertRating= (score)-> 
                saying = switch
                    when score < 1.5 then 'You should avoid this game!'
                    when score < 2.5 then 'Do not waste your time.'
                    when score < 3.5 then 'This game is below average.'
                    when score < 4   then 'You will find this game to be ok.'
                    when score < 4.5 then 'You should play this one!'
                    else 'You will love this game!'
            $scope.getGameStyle= (gameUrl)->  
                 return {'background': 'url("'+gameUrl+'")', 'background-size':'100% 150%', 'background-repeat':'no-repeat', 'background-position':'center'}

            $scope.colorForScore = (score)->
                saying = switch
                    when score < 1.5 then {'color': 'red', 'font-size':'12px'}
                    when score < 2.5 then {'color': 'red', 'font-size':'12px'}
                    when score < 3.5 then {'color': '#E6C805', 'font-size':'12px'}
                    when score < 4   then {'color': '#E6C805', 'font-size':'12px'}
                    when score < 4.5 then  {'color': 'green', 'font-size':'12px'}
                    else {'color': 'green', 'font-size':'12px'}
            	
            $ionicModal.fromTemplateUrl('views/gameDetailsModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) -> 
                $scope.gameDetailsModal = modal
                
            $scope.showGameDescription = (id, gameToShownName, image)->
                $scope.gameDetailsModal.show()
                $scope.gamedetails={}
                socket.emit 'getGameInfoFromWiki', id
            socket.on 'gameInfoForGameFromWiki' ,(data)->
                $scope.gamedetails= data.results
                $scope.gamedetails.name = gameToShownName
                $scope.gamedetails.image= image

            $scope.closeGameDes = ->
                $scope.gameDetailsModal.hide()
                
            $ionicModal.fromTemplateUrl('views/detailsGuruModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) -> 
                $scope.guruModal = modal
                $scope.modalGame = {}
            $scope.getGuruDetails = (id)->
                $scope.guruModal.show()
                
                socket.emit 'getGuruDetails' , {gameid: id} 
                $scope.guruInfoLoading = true
                socket.on 'guruDetailsFound' , (data)->
                    $scope.gameDetails= data
                    $scope.guruInfoLoading = false
            $scope.closeGuru = ()->
                $scope.guruModal.hide()
        
            $scope.closePeer = ()->
                $scope.peerModal.hide()
                    
            $scope.getPeerDetails = (id)->
                $scope.peerModal.show()
                socket.emit 'getPeerDetails', {gameid: id}
                $scope.peerInfoLoading = true
                socket.on 'peerDetailsFound', (data)->
                    $scope.gameDetails= data 
                    $scope.peerInfoLoading = false
                    
            $ionicModal.fromTemplateUrl('views/detailsPeerModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) -> 
                $scope.peerModal = modal
                $scope.modalGame = {}
        
signInSetup = ($scope, $ionicModal, socket)-> 
   $ionicModal.fromTemplateUrl('views/signupSignInModal.html' ,  {
        scope: $scope,
        animation: 'slide-in-up'
    }).then (modal) -> 
        $scope.modal = modal
        $scope.logdata = {}
    socket.on 'NeedUsername',()->
        $scope.modal.show()
        $scope.needUsername=true;
    $scope.createUsername = ->
        socket.emit 'addUsername', $scope.logdata.name
    socket.on 'usernameAdded' ,()->
        $scope.closeModal()
                
    statusChangeCallback =(response )->
        switch 
            when response.status is 'connected' 
                FB.api '/me', (fbresponse) ->
                    socket.emit 'loginToFaceBook', fbresponse
            when response.status is 'not_authorized' 
                $scope.errormessage ='You are not authorized'
            else
                 $scope.errormessage ='You are not authorized'
    
    window.checkLoginState =->
        FB.getLoginStatus (response)->
            statusChangeCallback(response)
    $scope.errormessage = false

    $scope.closeModal  = ->
        $scope.logdata = {}
        $scope.modal.hide()
    $scope.signUpModal = ->
        $scope.modal.show()
        $scope.signUp =true
    $scope.signInModal = ->
        $scope.modal.show()
        $scope.signUp =false
    $scope.signInOrSignUpNow =()->
        if $scope.signUp
            $scope.signUpNow()
        else 
            $scope.signInNow()
    $scope.signInNow = ->
        logdata = {}
        logdata.username = $scope.logdata.username
        logdata.password = $scope.logdata.temppassword 
        socket.emit 'Login', logdata
    $scope.signUpNow = ->
        $scope.logdata.password ={}
        logdata ={}
        password ={}
        if $scope.logdata.temppassword is $scope.logdata.repeat
            logdata.username = $scope.logdata.username
            logdata.password = $scope.logdata.temppassword
            logdata.name= $scope.logdata.name
            socket.emit 'SignUpUser', logdata
        else 
            $scope.errormessage ='Passwords do not match'
    socket.on 'UserEmailAlreadyExists' , ->
        $scope.errormessage ='The user already exits'
    socket.on 'UserEmailNotFound' , ->
        $scope.errormessage ='Email not valid'
    socket.on 'failureMessage', (message) ->
        $scope.errormessage = message
    socket.on 'userLoggedin', ->
        $scope.closeModal()
app.controller 'reviewController', 
    class reviewController
        @$inject : ['$scope', '$location', 'socket', '$ionicModal']
        constructor: (@$scope, @$location, @socket,  $ionicModal ) ->
            $scope.toggleClass = ->
                if $scope.active is 'false'
                    $scope.active = 'true'
                else 
                    $scope.active ='false'
            $scope.accessList=false  
            if $location.path() isnt '/home' && $location.path() isnt '/'
                isloggedin(socket,  $location.path())
            $scope.loggedin=true
            signInSetup $scope,$ionicModal,socket
            socket.on 'userLoggedin', (data)->
                $scope.accessList= data.accessList
                localStorage.setItem "sessionkey", data.sessionKey
            @$scope.homeSelected = 'button-stable'
            @$scope.logout= -> 
                localStorage.removeItem("sessionkey")
                window.location='#/home'
                $scope.accessList=false  
            @$scope.librarySelected = 'button-stable'
            @$scope.recomendationSeleted = 'button-stable'
            @$scope.isActive = (path)->
                path= '/'+path
                if path is nextPath = $location.path()
                    return 'pure-menu-selected'
                else 
                    return ''

app.controller 'homeController', 
	class homeController
        @$inject: ['$scope', '$ionicModal', 'socket']
        constructor: (@$scope,  $ionicModal, @socket) ->
            $scope.loggedin=false
            
            if window.localStorage.sessionkey
                socket.emit 'isUserLoggedin' , {key:window.localStorage.sessionkey , location:'/home'}
            socket.on 'userLoggedin', (data)->
                if data.location is '/home'
                    $scope.loggedin=true
                    window.location = '#/dashboard'

app.controller 'recommendationController', 
    class recommendationController
        @$inject: ['$scope', '$ionicModal', 'socket', '$location']
        constructor: (@$scope,  $ionicModal, @socket, @$location) ->
            $scope.isLoading=true;
            socket.emit 'GetListOfPlatforms' , {data:'1'}
            socket.on  'platformsFound', (data)->
                $scope.platforms =data
                $scope.isLoading=false;
                
app.controller 'searchController', 
	class searchController
        @$inject: ['$scope', '$ionicModal', 'socket', '$location']
        constructor: (@$scope,  $ionicModal, @socket, @$location) ->
            $scope.myLibrary=false
            $scope.isLoading =false
            $scope.scoreName='avgscore'
            $scope.loggedin=true
            $scope.SearchForAGame=false
            createGameDetailViewer $ionicModal, $scope, socket
            searchObject = $location.search();
            $scope.getGame=()->
                $scope.isLoading =true
                $scope.resultsFor=$scope.search
                socket.emit 'findGamesInWiki', $scope.resultsFor
            socket.on 'listOfGamesFromWiki', (data)->
                $scope.gamesfound=[]
                if data.results.length > 20
                    $scope.gamesfound=data.results[0..19]
                else
                    $scope.gamesfound=data.results
                socket.emit 'searchForGames' , {list: $scope.gamesfound}
            socket.on 'searchfinished' , (data)->
                $scope.games = []
                for item in data
                    if item.details
                        score1=item.details.guruscore
                        score2=item.details.peerscore
                        if score1 and score2 
                            item.details.avgscore= (score1*.75+score2*1.25)/2
                        else if score1 
                            item.details.avgscore= score1
                        else if score2
                            item.details.avgscore=score2
                    else
                        item.details={}
                        item.details.avgscore=0;
                    $scope.games.push item
                $scope.setUpPages();
                $scope.isLoading = false
            if typeof searchObject.game isnt "undefined"
                $scope.search= searchObject.game
                $scope.getGame()
            else 
                $scope.SearchForAGame=true
                $scope.isLoading = false
app.controller 'dashboardController',
	class dashboardController
        @$inject: ['$scope', '$ionicModal', 'socket']
        constructor: (@$scope,  $ionicModal, @socket) ->
            $scope.isLoading=true;
            socket.emit 'GetRecentGames'
            @socket.on 'recentReleases', (data)->
                $scope.isLoading=false;
                $scope.recentGames = data
            @socket.on 'noGames' , ()->
                $scope.isLoading=false
                $scope.recentGames = false
                
            createGameDetailViewer $ionicModal, $scope, socket

app.controller 'confidantController',
    class confidantController
        @$inject: ['$scope', '$ionicModal', 'socket','$location']
        constructor: (@$scope,  $ionicModal, @socket,@$location) ->
            socket.emit 'GetConfidants'
            $scope.getGameStyle= (picturename)->
                 return {'background': 'url("images/'+picturename+'")', 'background-size':'100% 100%%   ', 'background-repeat':'no-repeat', 'background-position':'center'}
            $scope.isLoading=true
            $scope.confidantSelected=false
            socket.on 'listOfFriends', (data)->
                $scope.myConfidants = data
                $scope.isLoading=false
            socket.on 'noFriendsFound',(data)->
                 $scope.isLoading=false
            socket.on 'noUsersFound', ()->
                $scope.noneFound= true
                $scope.isLoadingAdder = false
            socket.on 'listofPossibleConfidants',(data)->
                    $scope.confidantsFound= data
                    $scope.noneFound= false
                    $scope.isLoadingAdder = false
            $ionicModal.fromTemplateUrl('views/addConfidantModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) ->
                $scope.modal = modal
                $scope.newConfidant = {}
                $scope.selectConfidant = (confidant)->
                    $scope.confidantSelected=true
                    $scope.canFlip='flip'
                    $scope.newConfidant = confidant
                $scope.goback = ()->
                    $scope.confidantSelected=false
                    $scope.canFlip='false'
                    $scope.newConfidant = {}
                $scope.closeModal = ->
                    $scope.modal.hide()
                $scope.findConfidant =(requirements) ->
                    data ={search:requirements}
                    $scope.isLoadingAdder = true
                    socket.emit 'SearchForConfidants', data
                $scope.addConfidant = ()->
                    data = {friendid : $scope.newConfidant.id}
                    socket.emit 'AddConfidant', data
                    $scope.modal.hide()
                $scope.showConfidantAdder = ->
                    $scope.modal.show()

app.controller 'peerController',
	class peerController
        @$inject: ['$scope', '$ionicModal', 'socket','$location']
        constructor: (@$scope,  $ionicModal, @socket,@$location) ->
            $scope.myLibrary=false
            $scope.scoreName='avgscore'
            $scope.isLoading=true;
            searchObject = $location.search();
            socket.emit 'GetListOfPlatforms' , {data:'1'}
            socket.on  'platformsFound', (data)->
                $scope.platforms =data
            $scope.currentPlatform= searchObject.platform
            socket.emit 'GetPeerLibrary', searchObject.platform
            
            @socket.on 'peerLibraryFound', (data)->
                $scope.games = []
                for item in data[0]
                    score1=item.guruscore
                    score2=item.peerscore
                    if score1 and score2 
                        item.avgscore= (score1*.75+score2*1.25)/2
                    else if score1 
                        item.avgscore= score1
                    else if score2
                        item.avgscore=score2
                    $scope.games.push item
                $scope.setUpPages();
                $scope.isLoading=false;
            createGameDetailViewer $ionicModal, $scope, socket
            
app.controller 'guruController',
	class guruController
        @$inject: ['$scope', '$ionicModal', 'socket','$location']
        constructor: (@$scope,  $ionicModal, @socket,@$location) ->
            $scope.myLibrary=false
            $scope.scoreName='avgscore'
            $scope.isLoading=true;
            searchObject = $location.search();
            socket.emit 'GetListOfPlatforms' , {data:'1'}
            $scope.updatePlatform = (newPlatform)->
                $scope.isLoading=true;
                socket.emit 'GetGuruLibrary', newPlatform
                $scope.currentPlatform =newPlatform
            socket.on  'platformsFound', (data)->
                $scope.platforms =data
            $scope.updatePlatform searchObject.platform
            @socket.on 'guruLibraryFound', (data)->
                $scope.games = []
                for item in data[0]
                    score1=item.guruscore
                    score2=item.peerscore
                    if score1 and score2 
                        item.avgscore= (score1*.75+score2*1.25)/2
                    else if score1 
                        item.avgscore= score1
                    else if score2
                        item.avgscore=score2
                    $scope.games.push item
                $scope.setUpPages();
                $scope.isLoading=false;
            createGameDetailViewer $ionicModal, $scope, socket

app.controller 'genericController', 
    class genericController
        @$inject: ['$scope']
        constructor: (@$scope) ->
            $scope.contact=false

app.controller 'libraryController',
    class libraryController
        @$inject: ['$scope',   '$ionicModal', 'socket','$location']
        constructor: (@$scope,  $ionicModal, @socket, @$location) ->
         
            $scope.loggedin=true
            $scope.myLibrary=true
            $scope.NoLibraryError=false
            $scope.scoreName='rating'
            $scope.gameSelected=false
            $scope.isLoading=true;
            $scope.editMode =false
            $scope.saveLibraryEdit =()->
                socket.emit 'UpdateUserLibraryInfo' ,$scope.user
                $scope.editMode =false 
            
            $scope.toggleEditMode =()->
                $scope.editMode =!$scope.editMode
                
            path =$location.path();
            path = path.substring(1)
            $scope.Username = path;
            socket.emit 'GetLibrary' , path   
            @socket.on 'init', (data) -> 
            @socket.on 'noLibraryFound', (data)->
                $scope.NoLibraryError=true
            @socket.on 'gameLibraryFound', (data)->
                $scope.localLibrary=data.myLibrary
                $scope.user=data.user[0]
                $scope.games = []
                for item in data.games
                    score1=item.guruscore
                    score2=item.peerscore
                    if score1 and score2 
                        item.avgscore= (score1*.75+score2*1.25)/2
                    else if score1 
                        item.avgscore= score1
                    else if score2
                        item.avgscore=score2
                    $scope.games.push item
                $scope.setUpPages();
                $scope.isLoading=false;
                
            $ionicModal.fromTemplateUrl('views/addGameModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) -> 
                $scope.modal = modal
                $scope.modalGame = {}
            $scope.searchForAGame = (game)->
                $scope.isLoadingAdder = true
                socket.emit 'findGamesInWiki', game
            socket.on 'listOfGamesFromWiki', (data)->
                $scope.gamesfound=[]
                if data.results.length > 20
                    $scope.gamesfound=data.results[0..19]
                else
                    $scope.gamesfound=data.results
                $scope.isLoadingAdder = false
            	
            $scope.addNewGame = ->       
                $scope.modal.show()
                $scope.canFlip='false'
                $scope.gameSelected=false
            $scope.editUserResponse = (index) ->
                
            $scope.closeModal  = ->
                $scope.newgame={}
                $scope.gamesfound={}
                $scope.modal.hide()
            $scope.addGameToLibrary = (game)->
                $scope.newgame = {}
                $scope.canFlip='flip';
                $scope.newgame.userInfo={}
                $scope.newgame.giantBombinfo={}
                $scope.newgame.giantBombinfo.giantBomb_id= game.id
                $scope.newgame.giantBombinfo.game_name= game.name
                $scope.newgame.giantBombinfo.game_picture= game.image.medium_url
                $scope.newgame.giantBombinfo.description= game.deck 
                $scope.newgame.platforms=game.platforms
                $scope.newgame.userInfo.rating=3
                $scope.newgame.userInfo.enjoyment=3
                $scope.newgame.userInfo.length=3
                $scope.newgame.userInfo.unenjoyment=3
                $scope.newgame.userInfo.difficulty=3
                $scope.gameSelected=true
            $scope.importFromSteam = -> 
                $scope.vanity={}
                $ionicModal.fromTemplateUrl('views/steamImportModal.html' ,  {
                    scope: $scope,
                    animation: 'slide-in-up'
                }).then (modal)-> 
                    $scope.importModal = modal
                    $scope.importModal.show()
                    $scope.importMode=true
                    $scope.isTransfering=true
                    $scope.closeImportModal = ->
                        $scope.importModal.hide()
                    $scope.getGamesFromSteam = () ->
                        $scope.importMode=false
                        socket.emit 'importGamesFromSteam', $scope.vanity
            socket.on 'steamGamesToAdd', (data)->
                $scope.isTransfering=false
                $scope.newSteamGames=data
            socket.on 'vanityNameNotFound', (data)->
                $scope.vanityErrorMessage = data
            $scope.goback = ->
                $scope.canFlip='false'
                $scope.gameSelected=false
            $scope.saveGame = ()->
                socket.emit 'AddNewGameToLibrary', $scope.newgame
                $scope.closeModal()
                
            $ionicModal.fromTemplateUrl('views/detailsLibraryModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) -> 
                $scope.detailsModal = modal
            
            $scope.closeLibraryDetails=()->
                $scope.detailsModal.hide()
            
            $scope.getGameDetails=(game)->
                $scope.gamedetails=game
                $scope.gamedetails.reviewLink= $location.absUrl();
                $scope.detailsModal.show()
                
            $ionicModal.fromTemplateUrl('views/editScoreModal.html' ,  {
                scope: $scope,
                animation: 'slide-in-up'
            }).then (modal) -> 
                $scope.editModal = modal
                $scope.edit = {}
            $scope.closeEdit  = ()->
                $scope.editModal.hide()
                $scope.edit = {}
            $scope.showEdit = (game)->
                $scope.edit=game
                $scope.editModal.show()
          
            $scope.updateGame = ->
                socket.emit 'updateGame', $scope.edit
                $scope.editModal.hide()
            createGameDetailViewer $ionicModal, $scope, socket

