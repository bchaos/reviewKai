// Generated by CoffeeScript 1.6.3
(function() {
  var app, createGameDetailViewer, dashboardController, guruController, homeController, isloggedin, libraryController, peerController, proController, proLibraryController, reviewController, searchController, signInSetup;

  app = angular.module('reviewApp', ['ngAnimate', 'ngRoute', 'ngResource', 'ngSanitize', 'ionic'], function($routeProvider, $locationProvider) {
    $routeProvider.when('/library', {
      templateUrl: 'views/library.html',
      controller: 'libraryController'
    });
    $routeProvider.when('/guru', {
      templateUrl: 'views/library.html',
      controller: 'guruController'
    });
    $routeProvider.when('/home', {
      templateUrl: 'views/home.html',
      controller: 'homeController'
    });
    $routeProvider.when('/faqs', {
      templateUrl: 'views/faqs.html'
    });
    $routeProvider.when('/contact', {
      templateUrl: 'views/contact.html'
    });
    $routeProvider.when('/peer', {
      templateUrl: 'views/library.html',
      controller: 'peerController'
    });
    $routeProvider.when('/dashboard', {
      templateUrl: 'views/dashboard.html',
      controller: 'dashboardController'
    });
    $routeProvider.when('/settings', {
      templateUrl: 'views/settings.html',
      controller: 'settingsController'
    });
    $routeProvider.when('/search', {
      templateUrl: 'views/search.html',
      controller: 'searchController'
    });
    $routeProvider.when('/pros', {
      templateUrl: 'views/Pros.html',
      controller: 'proController'
    });
    $routeProvider.when('/prosLibrary', {
      templateUrl: 'views/ProReviewerLibrary.html',
      controller: 'proLibraryController'
    });
    return $routeProvider.otherwise({
      templateUrl: 'views/home.html',
      controller: 'homeController'
    });
  });

  app.config(function($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    return delete $httpProvider.defaults.headers.common['X-Requested-With'];
  });

  app.service('socket', function($rootScope) {
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
  });

  /* move this to the server*/


  app.factory('InfoRequestService', [
    '$http', function($http) {
      var InfoRequest;
      InfoRequest = (function() {
        function InfoRequest() {}

        InfoRequest.prototype.searchForAGame = function(game, callback) {
          var GamesSearchUrl, request;
          request = {
            api_key: '059d37ad5ca7f47e566180366eab2190e8c6da30',
            query: game,
            format: "jsonp",
            field_list: "name, image, site_detail_url"
          };
          GamesSearchUrl = 'http://www.giantbomb.com/api/search/?api_key=059d37ad5ca7f47e566180366eab2190e8c6da30&query=' + game + '&field_list=name,image,id,description,original_release_date,genres&resources=game&format=jsonp&json_callback=JSON_CALLBACK';
          return $http.jsonp(GamesSearchUrl).success(function(data) {
            return callback(data);
          });
        };

        return InfoRequest;

      })();
      return new InfoRequest();
    }
  ]);

  isloggedin = function(socket, location) {
    if (window.localStorage.sessionkey) {
      socket.emit('isUserLoggedin', {
        key: window.localStorage.sessionkey,
        location: location
      });
    } else {
      window.location = '#/home';
    }
    return socket.on('failedToLogin', function(data) {
      return window.location = '#/home';
    });
  };

  createGameDetailViewer = function($ionicModal, $scope, socket) {
    $scope.gameDetails = [];
    $scope.sort = '-releasedate';
    $scope.convertMyRating = function(score) {
      var saying;
      return saying = (function() {
        switch (false) {
          case score !== 1:
            return 'This game is  unplayable';
          case score !== 2:
            return 'Bad but playable in a pinch';
          case score !== 3:
            return 'A fairly average game';
          case score !== 4:
            return 'Good game with some minor flaws';
          default:
            return 'A nearly flawless gameplay experience';
        }
      })();
    };
    $scope.convertRating = function(score) {
      var saying;
      return saying = (function() {
        switch (false) {
          case !(score < 1.5):
            return 'Avoid this game at all costs!';
          case !(score < 2.5):
            return 'We should not have played this!';
          case !(score < 3.5):
            return 'This game is pretty bad!';
          case !(score < 4):
            return 'Play this game if you have nothing else.';
          case !(score < 4.5):
            return 'This game is Pretty Great!';
          default:
            return 'This game is Amazing!';
        }
      })();
    };
    $scope.colorForScore = function(score) {
      if (score >= 3.5) {
        return {
          'color': 'green',
          'font-size': '20px'
        };
      } else if (score > 2.5) {
        return {
          'color': '#E6C805',
          'font-size': '18px'
        };
      }
      return {
        'color': 'red',
        'font-size': '16px'
      };
    };
    $ionicModal.fromTemplateUrl('views/detailsGuruModal.html', {
      scope: $scope,
      animation: 'slide-in-up'
    }).then(function(modal) {
      $scope.guruModal = modal;
      return $scope.modalGame = {};
    });
    $scope.getGuruDetails = function(id) {
      $scope.guruModal.show();
      socket.emit('getGuruDetails', {
        gameid: id
      });
      return $scope.guruInfoLoading = true;
    };
    socket.on('guruDetailsFound', function(data) {
      $scope.gameDetails = data;
      return $scope.guruInfoLoading = false;
    });
    $scope.closeGuru = function() {
      return $scope.guruModal.hide();
    };
    $scope.closePeer = function() {
      return $scope.peerModal.hide();
    };
    $scope.getPeerDetails = function(id) {
      $scope.peerModal.show();
      socket.emit('getPeerDetails', {
        gameid: id
      });
      $scope.peerInfoLoading = true;
      return socket.on('peerDetailsFound', function(data) {
        $scope.gameDetails = data;
        return $scope.peerInfoLoading = false;
      });
    };
    return $ionicModal.fromTemplateUrl('views/detailsPeerModal.html', {
      scope: $scope,
      animation: 'slide-in-up'
    }).then(function(modal) {
      $scope.peerModal = modal;
      return $scope.modalGame = {};
    });
  };

  signInSetup = function($scope, $ionicModal, socket) {
    $ionicModal.fromTemplateUrl('views/signupSignInModal.html', {
      scope: $scope,
      animation: 'slide-in-up'
    }).then(function(modal) {
      $scope.modal = modal;
      return $scope.logdata = {};
    });
    $scope.errormessage = false;
    $scope.closeModal = function() {
      $scope.logdata = {};
      return $scope.modal.hide();
    };
    $scope.signUpModal = function() {
      $scope.modal.show();
      return $scope.signUp = true;
    };
    $scope.signInModal = function() {
      $scope.modal.show();
      return $scope.signUp = false;
    };
    $scope.signInNow = function() {
      var logdata;
      logdata = {};
      logdata.username = $scope.logdata.username;
      logdata.password = $scope.logdata.temppassword;
      return socket.emit('Login', logdata);
    };
    $scope.signUpNow = function() {
      var logdata, password;
      $scope.logdata.password = {};
      logdata = {};
      password = {};
      if ($scope.logdata.temppassword === $scope.logdata.repeat) {
        logdata.username = $scope.logdata.username;
        logdata.password = $scope.logdata.temppassword;
        logdata.name = $scope.logdata.name;
        return socket.emit('SignUpUser', logdata);
      } else {
        return $scope.errormessage = 'Passwords do not match';
      }
    };
    socket.on('UserEmailAlreadyExists', function() {
      return $scope.errormessage = 'The user already exits';
    });
    socket.on('UserEmailNotFound', function() {
      return $scope.errormessage = 'Email not valid';
    });
    socket.on('failureMessage', function(message) {
      return $scope.errormessage = message;
    });
    return socket.on('userLoggedin', function() {
      return $scope.closeModal();
    });
  };

  app.controller('reviewController', reviewController = (function() {
    reviewController.$inject = ['$scope', 'InfoRequestService', '$location', 'socket', '$ionicModal'];

    function reviewController($scope, InfoRequestService, $location, socket, $ionicModal) {
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.$location = $location;
      this.socket = socket;
      if ($location.path() !== '/home' && $location.path() !== '/') {
        isloggedin(socket, $location.path());
      }
      $scope.loggedin = true;
      signInSetup($scope, $ionicModal, socket);
      socket.on('userLoggedin', function(data) {
        $scope.accessList = data.accessList;
        return localStorage.setItem("sessionkey", data.sessionKey);
      });
      this.$scope.homeSelected = 'button-stable';
      this.$scope.logout = function() {
        localStorage.removeItem("sessionkey");
        window.location = '#/home';
        return $scope.accessList = false;
      };
      this.$scope.librarySelected = 'button-stable';
      this.$scope.recomendationSeleted = 'button-stable';
      this.$scope.isActive = function(path) {
        var nextPath;
        path = '/' + path;
        if (path === (nextPath = $location.path())) {
          return 'pure-menu-selected';
        } else {
          return '';
        }
      };
    }

    return reviewController;

  })());

  app.controller('homeController', homeController = (function() {
    homeController.$inject = ['$scope', '$ionicModal', 'socket'];

    function homeController($scope, $ionicModal, socket) {
      this.$scope = $scope;
      this.socket = socket;
      $scope.loggedin = false;
      if (window.localStorage.sessionkey) {
        socket.emit('isUserLoggedin', {
          key: window.localStorage.sessionkey,
          location: '/home'
        });
      }
      signInSetup($scope, $ionicModal, socket);
      socket.on('userLoggedin', function(data) {
        if (data.location === '/home') {
          $scope.loggedin = true;
          return window.location = '#/dashboard';
        }
      });
    }

    return homeController;

  })());

  app.controller('searchController', searchController = (function() {
    searchController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket', '$location'];

    function searchController($scope, InfoRequestService, $ionicModal, socket, $location) {
      var searchObject;
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      this.$location = $location;
      $scope.myLibrary = false;
      $scope.isLoading = true;
      $scope.scoreName = 'peerscore';
      $scope.loggedin = true;
      socket.on('userLoggedin', function(data) {});
      createGameDetailViewer($ionicModal, $scope, socket);
      searchObject = $location.search();
      InfoRequestService.searchForAGame(searchObject.game, function(data) {
        $scope.gamesfound = [];
        if (data.results.length > 15) {
          $scope.gamesfound = data.results.slice(0, 15);
        } else {
          $scope.gamesfound = data.results;
        }
        socket.emit('searchForGames', {
          list: $scope.gamesfound
        });
        return socket.on('searchfinished', function(data) {
          $scope.searchResults = data;
          return $scope.isLoading = false;
        });
      });
    }

    return searchController;

  })());

  app.controller('dashboardController', dashboardController = (function() {
    dashboardController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket'];

    function dashboardController($scope, InfoRequestService, $ionicModal, socket) {
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      $scope.scoreName = 'peerscore';
      socket.emit('GetRecentGames');
      this.socket.on('recentReleases', function(data) {
        return $scope.recentGames = data;
      });
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return dashboardController;

  })());

  app.controller('peerController', peerController = (function() {
    peerController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket'];

    function peerController($scope, InfoRequestService, $ionicModal, socket) {
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      $scope.myLibrary = false;
      $scope.scoreName = 'peerscore';
      socket.emit('GetPeerLibrary');
      this.socket.on('peerLibraryFound', function(data) {
        return $scope.games = data;
      });
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return peerController;

  })());

  app.controller('guruController', guruController = (function() {
    guruController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket'];

    function guruController($scope, InfoRequestService, $ionicModal, socket) {
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      $scope.myLibrary = false;
      $scope.scoreName = 'guruscore';
      socket.emit('GetGuruLibrary');
      this.socket.on('guruLibraryFound', function(data) {
        return $scope.games = data;
      });
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return guruController;

  })());

  app.controller('libraryController', libraryController = (function() {
    libraryController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket'];

    function libraryController($scope, InfoRequestService, $ionicModal, socket) {
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      $scope.loggedin = true;
      $scope.myLibrary = true;
      $scope.scoreName = 'rating';
      $scope.gameSelected = false;
      socket.emit('GetLibrary');
      this.$scope.aquiredGameList = function() {};
      this.socket.on('init', function(data) {});
      this.socket.on('gameLibraryFound', function(data) {
        return $scope.games = data;
      });
      $ionicModal.fromTemplateUrl('views/addGameModal.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        $scope.modal = modal;
        return $scope.modalGame = {};
      });
      $scope.searchForAGame = function(game) {
        $scope.isLoading = true;
        return InfoRequestService.searchForAGame(game, function(data) {
          $scope.gamesfound = data.results;
          return $scope.isLoading = false;
        });
      };
      $scope.addNewGame = function() {
        $scope.modal.show();
        return $scope.gameSelected = false;
      };
      $scope.editUserResponse = function(index) {};
      $scope.closeModal = function() {
        $scope.newgame = {};
        $scope.gamesfound = {};
        return $scope.modal.hide();
      };
      $scope.addGameToLibrary = function(game) {
        $scope.newgame = {};
        $scope.newgame.userInfo = {};
        $scope.newgame.giantBombinfo = {};
        $scope.newgame.giantBombinfo.giantBomb_id = game.id;
        $scope.newgame.giantBombinfo.game_name = game.name;
        $scope.newgame.giantBombinfo.game_picture = game.image.medium_url;
        $scope.newgame.giantBombinfo.description = game.deck;
        $scope.newgame.userInfo.rating = 3;
        $scope.newgame.userInfo.enjoyment = 3;
        $scope.newgame.userInfo.length = 3;
        $scope.newgame.userInfo.unenjoyment = 3;
        $scope.newgame.userInfo.difficulty = 3;
        return $scope.gameSelected = true;
      };
      $scope.goback = function() {
        return $scope.gameSelected = false;
      };
      $scope.saveGame = function() {
        socket.emit('AddNewGameToLibrary', $scope.newgame);
        return $scope.closeModal();
      };
      $ionicModal.fromTemplateUrl('views/editScoreModal.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        $scope.editModal = modal;
        return $scope.edit = {};
      });
      $scope.closeEdit = function() {
        $scope.editModal.hide();
        return $scope.edit = {};
      };
      $scope.showEdit = function(index) {
        $scope.edit = $scope.games[index];
        return $scope.editModal.show();
      };
      $scope.updateGame = function() {
        socket.emit('updateGame', $scope.edit);
        return $scope.editModal.hide();
      };
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return libraryController;

  })());

  app.controller('proController', proController = (function() {
    proController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket'];

    function proController($scope, InfoRequestService, $ionicModal, socket) {
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      $scope.myLibrary = true;
      $scope.scoreName = 'rating';
      socket.emit('GetProreviewers', 'all');
      socket.on('ProreviewersFound', function(data) {
        return $scope.reviewers = data;
      });
      $ionicModal.fromTemplateUrl('views/addPro.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        $scope.proModal = modal;
        return $scope.pros = {};
      });
      $scope.closeProModal = function() {
        return $scope.proModal.hide();
      };
      $scope.openProModal = function(id) {
        $scope.proModal.show();
        if (id) {
          $scope.mode = true;
          $scope.newPro.id = id;
        } else {
          $scope.mode = false;
        }
        return $scope.newPro = {};
      };
      $scope.editPro = function() {
        socket.emit('editPro', $scope.newPro);
        return $scope.closeProModal();
      };
      $scope.savePro = function() {
        socket.emit('addPro', $scope.newPro);
        return $scope.closeProModal();
      };
    }

    return proController;

  })());

  app.controller('proLibraryController', proLibraryController = (function() {
    proLibraryController.$inject = ['$scope', 'InfoRequestService', '$ionicModal', 'socket', '$location'];

    function proLibraryController($scope, InfoRequestService, $ionicModal, socket, $location) {
      var searchObject;
      this.$scope = $scope;
      this.InfoRequestService = InfoRequestService;
      this.socket = socket;
      this.$location = $location;
      $scope.myLibrary = true;
      $scope.scoreName = 'rating';
      $scope.gameSelected = false;
      searchObject = $location.search();
      socket.emit('GetProreviewerLibrary', {
        id: searchObject.reviewerid
      });
      socket.on('ProLibrarysFound', function(data) {
        return $scope.games = data;
      });
      $ionicModal.fromTemplateUrl('views/addProGame.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        $scope.modal = modal;
        return $scope.modalGame = {};
      });
      $scope.searchForAGame = function(game) {
        $scope.isLoading = true;
        return InfoRequestService.searchForAGame(game, function(data) {
          $scope.gamesfound = data.results;
          return $scope.isLoading = false;
        });
      };
      $scope.addNewGame = function() {
        $scope.modal.show();
        return $scope.gameSelected = false;
      };
      $scope.editUserResponse = function(index) {};
      $scope.closeModal = function() {
        $scope.newgame = {};
        $scope.gamesfound = {};
        return $scope.modal.hide();
      };
      $scope.addGameToLibrary = function(game) {
        $scope.newgame = {};
        $scope.newgame.userInfo = {};
        $scope.newgame.userInfo.user_id = searchObject.reviewerid;
        $scope.newgame.giantBombinfo = {};
        $scope.newgame.giantBombinfo.giantBomb_id = game.id;
        $scope.newgame.giantBombinfo.game_name = game.name;
        $scope.newgame.giantBombinfo.game_picture = game.image.medium_url;
        $scope.newgame.giantBombinfo.description = game.deck;
        $scope.newgame.giantBombinfo.releasedate = game.original_release_date;
        return $scope.gameSelected = true;
      };
      $scope.goback = function() {
        return $scope.gameSelected = false;
      };
      $scope.saveGame = function() {
        socket.emit('AddNewProGameToLibrary', $scope.newgame);
        return $scope.closeModal();
      };
    }

    return proLibraryController;

  })());

}).call(this);
