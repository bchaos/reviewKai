(function() {
  var dataparserController;

  dataparserController = function($scope, InfoRequestService, socket) {
    var addGameToLibrary, addPlatforms;
    this.$scope = $scope;
    this.InfoRequestService = InfoRequestService;
    this.socket = socket;
    $scope.getMetaData = function() {
      return InfoRequestService.getMetaData($scope.metacriticlink, function(data) {
        var metacriticdata;
        return metacriticdata = data;
      });
    };
    addGameToLibrary = function(index, length, gameData, callback) {
      if (index === length) {
        callback();
      }
      if (!gameData[index].game) {
        gameData[index].giantBombinfo = gameData[index - 1].giantBombinfo;
        socket.emit('AddGameandReviewerToLibrary', gameData[index]);
        return addGameToLibrary(index + 1, length, gameData, callback);
      } else {
        return InfoRequestService.searchForAGame(gameData[index].game, function(data) {
          var game;
          if (data.results.length === 0) {
            addGameToLibrary(index + 1, length, gameData, callback);
          }
          game = data.results[0];
          gameData[index].giantBombinfo = {};
          gameData[index].giantBombinfo.giantBomb_id = game.id;
          gameData[index].giantBombinfo.game_name = game.name;
          gameData[index].platforms = game.platforms;
          if (game.image) {
            gameData[index].giantBombinfo.game_picture = game.image.medium_url;
          } else {
            gameData[index].giantBombinfo.game_picture = '';
          }
          gameData[index].giantBombinfo.description = game.deck;
          gameData[index].giantBombinfo.releasedate = game.original_release_date;
          socket.emit('AddGameandReviewerToLibrary', gameData[index]);
          return addGameToLibrary(index + 1, length, gameData, callback);
        });
      }
    };
    addPlatforms = function(games, index, length, callback) {
      if (index === length) {
        return callback(true);
      } else {
        return InfoRequestService.getDeckForGame(games[index].bombid, function(data) {
          var newdata;
          newdata = data.results;
          newdata.id = games[index].gameid;
          socket.emit('updateGamePlatforms', newdata);
          return addPlatforms(games, index + 1, length, callback);
        });
      }
    };
    $scope.updateGamePlatforms = function(files) {
      var file, reader;
      file = files[0];
      reader = new FileReader();
      reader.readAsText(file);
      return reader.onload = function(event) {
        var csv, curdata, length;
        csv = event.target.result;
        curdata = $.csv.toObjects(csv);
        length = curdata.length;
        return addPlatforms(curdata, 0, length, function() {
          return alert(finished);
        });
      };
    };
    return $scope.uploadImage = function(files) {
      var file, reader;
      file = files[0];
      reader = new FileReader();
      reader.readAsText(file);
      return reader.onload = function(event) {
        var OrganizedData, csv, data, gamedata, length, organized, _i, _len;
        csv = event.target.result;
        data = $.csv.toObjects(csv);
        OrganizedData = [];
        length = 0;
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          gamedata = data[_i];
          length++;
          organized = {};
          organized.pro = {};
          organized.pro.name = gamedata.name;
          organized.pro.site_address = gamedata.Site_address;
          organized.userInfo = {};
          organized.game = gamedata.game;
          organized.userInfo.review_link = gamedata.review_link;
          organized.userInfo.true_score = gamedata.true_score;
          if (gamedata.true_score > 10) {
            organized.userInfo.true_score_max = 100;
            organized.userInfo.rating = gamedata.true_score / 20;
          } else if (gamedata.true_score > 5) {
            organized.userInfo.true_score_max = 10;
            organized.userInfo.rating = gamedata.true_score / 2;
          } else {
            organized.userInfo.true_score_max = 5;
            organized.userInfo.rating = gamedata.true_score;
          }
          OrganizedData.push(organized);
        }
        return addGameToLibrary(0, length, OrganizedData, function() {
          return alert('finished');
        });
      };
    };
  };

  dataparserController.inject = ['$scope', 'InfoRequestService', 'socket'];

  angular.module('reviewApp', ['ngAnimate', 'ngRoute', 'ngResource', 'ngSanitize', 'ionic']).service('socket', function($rootScope) {
    var socket;
    socket = io.connect('http://166.78.129.57:8080');
    return {
      on: function(eventname, callback) {
        return socket.on(eventname, function() {
          var args;
          args = arguments;
          return $rootScope.$apply(function() {
            return callback.apply(socket, args);
          });
        });
      },
      emit: function(eventName, data, callback) {
        return socket.emit(eventName, data, function() {
          var args;
          args = arguments;
          return $rootScope.$apply(function() {
            if (callback) {
              return callback.apply(socket, args);
            }
          });
        });
      }
    };
  }).factory('InfoRequestService', [
    '$http', function($http) {
      var InfoRequest;
      InfoRequest = (function() {
        function InfoRequest() {}

        InfoRequest.prototype.searchForAGame = function(game, callback) {
          var GamesSearchUrl;
          GamesSearchUrl = 'http://www.giantbomb.com/api/search/?api_key=059d37ad5ca7f47e566180366eab2190e8c6da30&query=' + game + '&field_list=name,image,id,deck,original_release_date,platforms,genres&resources=game&format=jsonp&json_callback=JSON_CALLBACK';
          return $http.jsonp(GamesSearchUrl).success(function(data) {
            return callback(data);
          });
        };

        InfoRequest.prototype.getDeckForGame = function(gameid, callback) {
          var GamesSearchUrl;
          GamesSearchUrl = 'http://www.giantbomb.com/api/game/' + gameid + '/?api_key=059d37ad5ca7f47e566180366eab2190e8c6da30&field_list=platforms,deck,genres,videos,original_release_date&format=jsonp&json_callback=JSON_CALLBACK';
          return $http.jsonp(GamesSearchUrl).success(function(data) {
            return callback(data);
          });
        };

        InfoRequest.prototype.getMetaData = function(link, callback) {
          return $http.get(link).success(function(data) {
            return callback(data);
          });
        };

        return InfoRequest;

      })();
      return new InfoRequest();
    }
  ]).controller('dataparserController', dataparserController);

}).call(this);
