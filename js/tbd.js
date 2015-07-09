(function() {
  var app, confidantController, createGameDetailViewer, dashboardController, genericController, guruController, homeController, isloggedin, libraryController, peerController, recommendationController, reviewController, searchController, signInSetup;

  app = angular.module('reviewApp', ['ngAnimate', 'ngRoute', 'ngResource', 'ngSanitize', 'ionic'], function($routeProvider, $locationProvider) {
    $routeProvider.when('/library', {
      templateUrl: 'views/library.html',
      controller: 'libraryController'
    });
    $routeProvider.when('/guru', {
      templateUrl: 'views/library.html',
      controller: 'guruController'
    });
    $routeProvider.when('/', {
      templateUrl: 'views/home.html',
      controller: 'homeController'
    });
    $routeProvider.when('/home', {
      templateUrl: 'views/home.html',
      controller: 'homeController'
    });
    $routeProvider.when('/faqs', {
      templateUrl: 'views/faqs.html'
    });
    $routeProvider.when('/contact', {
      templateUrl: 'views/contact.html',
      controller: 'genericController'
    });
    $routeProvider.when('/confidants', {
      templateUrl: 'views/confidants.html',
      controller: 'confidantController'
    });
    $routeProvider.when('/PrivacyPolicy', {
      templateUrl: 'views/PrivacyPolicy.html',
      controller: 'genericController'
    });
    $routeProvider.when('/recommendations', {
      templateUrl: 'views/recommendations.html',
      controller: 'recommendationController'
    });
    $routeProvider.when('/blog', {
      templateUrl: 'views/blog.html'
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
      controller: 's'
    });
    $routeProvider.when('/search', {
      templateUrl: 'views/search.html',
      controller: 'searchController'
    });
    return $routeProvider.otherwise({
      templateUrl: 'views/library.html',
      controller: 'libraryController'
    });
  });

  app.directive('platfromcard', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/platformcard.html'
    };
  });

  app.directive('confidantcard', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/confidantCard.html'
    };
  });

  app.directive('card', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/card.html'
    };
  });

  app.directive('searching', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/searching.html'
    };
  });

  app.directive('librarycard', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/librarycard.html'
    };
  });

  app.directive('searchcard', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/searchcard.html'
    };
  });

  app.directive('steamtransfer', function() {
    return {
      restrict: 'E',
      templateUrl: 'views/steamTransfer.html'
    };
  });

  app.config(function($httpProvider) {
    $httpProvider.defaults.useXDomain = true;
    return delete $httpProvider.defaults.headers.common['X-Requested-With'];
  });

  app.service('socket', function($rootScope) {
    var socket;
    socket = io.connect('http://Reviewkai.com:8080');
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

  app.filter('myLimitTo', [
    function() {
      return function(obj, limit, offset) {
        var count, keys, ret, startingpoint;
        keys = Object.keys(obj);
        if (keys.length < 1) {
          return [];
        }
        ret = new Object;
        count = 0;
        startingpoint = 0;
        angular.forEach(keys, function(key, arrayIndex) {
          if (count >= limit) {
            return false;
          }
          if (startingpoint >= offset) {
            ret[key] = obj[key];
            return count++;
          } else {
            return startingpoint >= offset++;
          }
        });
        return ret;
      };
    }
  ]);

  isloggedin = function(socket, location) {
    if (window.localStorage.sessionkey) {
      return socket.emit('isUserLoggedin', {
        key: window.localStorage.sessionkey,
        location: location
      });
    }
  };

  createGameDetailViewer = function($ionicModal, $scope, socket) {
    var createNumberList;
    $scope.newOffset = 0;
    if ($scope.myLibrary && $scope.localLibrary) {
      $scope.itemsPerPage = 11;
    } else {
      $scope.itemsPerPage = 12;
    }
    $scope.currentPage = 0;
    $scope.onCurrentPage = function(num) {
      if (num === $scope.currentPage) {
        return 'button-balanced';
      }
      return 'button-stable';
    };
    $scope.setUpPages = function() {
      var pagecount;
      pagecount = Math.ceil($scope.games.length / $scope.itemsPerPage);
      $scope.maxPages = pagecount;
      $scope.pages = [];
      return createNumberList();
    };
    createNumberList = function() {
      var firstPage, hasElispes, i, lastPage, length, _i;
      lastPage = $scope.maxPages;
      firstPage = 0;
      $scope.pages = [];
      length = 9;
      hasElispes = false;
      if ($scope.maxPages > length + 1 && $scope.currentPage + 4 >= $scope.maxPages - 1) {
        firstPage = $scope.maxPages - length;
        lastPage = $scope.maxPages;
      } else if ($scope.maxPages > length + 1 && $scope.currentPage >= length - 1) {
        firstPage = $scope.currentPage - 4;
        lastPage = $scope.currentPage + 4;
      } else if ($scope.maxPages > length + 1) {
        lastPage = length;
      }
      if (firstPage > 0) {
        $scope.pages.push({
          number: 0,
          startingPoint: 0
        });
        $scope.pages.push({
          elispe: true,
          number: false
        });
      }
      for (i = _i = firstPage; firstPage <= lastPage ? _i < lastPage : _i > lastPage; i = firstPage <= lastPage ? ++_i : --_i) {
        $scope.pages.push({
          number: i,
          startingPoint: i * $scope.itemsPerPage
        });
      }
      if (lastPage < $scope.maxPages - 1) {
        $scope.pages.push({
          elispe: true,
          number: false
        });
        return $scope.pages.push({
          number: $scope.maxPages - 1,
          startingPoint: ($scope.maxPages - 1) * $scope.itemsPerPage
        });
      }
    };
    $scope.setPage = function(num) {
      if (num >= 0 && num < $scope.maxPages) {
        $scope.currentPage = num;
        $scope.newOffset = $scope.currentPage * $scope.itemsPerPage;
        return createNumberList();
      }
    };
    $scope.gameDetails = {};
    $scope.sort = '-releasedate';
    $scope.convertMyRating = function(score) {
      var saying;
      score = parseInt(score);
      if (score > 10) {
        score = score / 20;
      }
      if (score > 5) {
        score = score / 2;
      }
      return saying = (function() {
        switch (false) {
          case score !== -1:
            return 'I need to rate this game';
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
    $scope.convertAverageLibraryClass = function(score, rating, islibrary) {
      if (!islibrary) {
        return $scope.convertAverageClass(score);
      } else {
        return $scope.convertAverageClass(rating);
      }
    };
    $scope.convertAverageClass = function(score) {
      var saying;
      if (!score || score === 0 || score === -1) {
        return 'unknown';
      }
      return saying = (function() {
        switch (false) {
          case !(score < 1.5):
            return 'negative';
          case !(score < 2.5):
            return 'negative';
          case !(score < 3.5):
            return 'ok';
          case !(score < 4):
            return 'ok';
          case !(score < 4.5):
            return 'postive';
          default:
            return 'postive';
        }
      })();
    };
    $scope.convertRating = function(score) {
      var saying;
      return saying = (function() {
        switch (false) {
          case !(score < 1.5):
            return 'You should avoid this game!';
          case !(score < 2.5):
            return 'Do not waste your time.';
          case !(score < 3.5):
            return 'This game is below average.';
          case !(score < 4):
            return 'You will find this game to be ok.';
          case !(score < 4.5):
            return 'You should play this one!';
          default:
            return 'You will love this game!';
        }
      })();
    };
    $scope.getGameStyle = function(gameUrl) {
      return {
        'background': 'url("' + gameUrl + '")',
        'background-size': '100% 150%',
        'background-repeat': 'no-repeat',
        'background-position': 'center'
      };
    };
    $scope.colorForScore = function(score) {
      var saying;
      return saying = (function() {
        switch (false) {
          case !(score < 1.5):
            return {
              'color': 'red',
              'font-size': '12px'
            };
          case !(score < 2.5):
            return {
              'color': 'red',
              'font-size': '12px'
            };
          case !(score < 3.5):
            return {
              'color': '#E6C805',
              'font-size': '12px'
            };
          case !(score < 4):
            return {
              'color': '#E6C805',
              'font-size': '12px'
            };
          case !(score < 4.5):
            return {
              'color': 'green',
              'font-size': '12px'
            };
          default:
            return {
              'color': 'green',
              'font-size': '12px'
            };
        }
      })();
    };
    $ionicModal.fromTemplateUrl('views/gameDetailsModal.html', {
      scope: $scope,
      animation: 'slide-in-up'
    }).then(function(modal) {
      return $scope.gameDetailsModal = modal;
    });
    $scope.showGameDescription = function(id, gameToShownName, image) {
      $scope.gameDetailsModal.show();
      $scope.gamedetails = {};
      return socket.emit('getGameInfoFromWiki', id);
    };
    socket.on('gameInfoForGameFromWiki', function(data) {
      $scope.gamedetails = data.results;
      $scope.gamedetails.name = gameToShownName;
      return $scope.gamedetails.image = image;
    });
    $scope.closeGameDes = function() {
      return $scope.gameDetailsModal.hide();
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
      $scope.guruInfoLoading = true;
      return socket.on('guruDetailsFound', function(data) {
        $scope.gameDetails = data;
        return $scope.guruInfoLoading = false;
      });
    };
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
    var statusChangeCallback;
    $ionicModal.fromTemplateUrl('views/signupSignInModal.html', {
      scope: $scope,
      animation: 'slide-in-up'
    }).then(function(modal) {
      $scope.modal = modal;
      return $scope.logdata = {};
    });
    socket.on('NeedUsername', function() {
      $scope.modal.show();
      return $scope.needUsername = true;
    });
    $scope.createUsername = function() {
      return socket.emit('addUsername', $scope.logdata.name);
    };
    socket.on('usernameAdded', function() {
      return $scope.closeModal();
    });
    statusChangeCallback = function(response) {
      switch (false) {
        case response.status !== 'connected':
          return FB.api('/me', function(fbresponse) {
            return socket.emit('loginToFaceBook', fbresponse);
          });
        case response.status !== 'not_authorized':
          return $scope.errormessage = 'You are not authorized';
        default:
          return $scope.errormessage = 'You are not authorized';
      }
    };
    window.checkLoginState = function() {
      return FB.getLoginStatus(function(response) {
        return statusChangeCallback(response);
      });
    };
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
    $scope.signInOrSignUpNow = function() {
      if ($scope.signUp) {
        return $scope.signUpNow();
      } else {
        return $scope.signInNow();
      }
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
    reviewController.$inject = ['$scope', '$location', 'socket', '$ionicModal'];

    function reviewController($scope, $location, socket, $ionicModal) {
      this.$scope = $scope;
      this.$location = $location;
      this.socket = socket;
      $scope.toggleClass = function() {
        if ($scope.active === 'false') {
          return $scope.active = 'true';
        } else {
          return $scope.active = 'false';
        }
      };
      $scope.accessList = false;
      if ($location.path() !== '/home' && $location.path() !== '/') {
        isloggedin(socket, $location.path());
      }
      $scope.loggedin = true;
      signInSetup($scope, $ionicModal, socket);
      socket.on('goToLogin', function() {
        return isloggedin(socket, $location.path());
      });
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
      socket.on('userLoggedin', function(data) {
        if (data.location === '/home') {
          $scope.loggedin = true;
          return window.location = '#/dashboard';
        }
      });
    }

    return homeController;

  })());

  app.controller('recommendationController', recommendationController = (function() {
    recommendationController.$inject = ['$scope', '$ionicModal', 'socket', '$location'];

    function recommendationController($scope, $ionicModal, socket, $location) {
      this.$scope = $scope;
      this.socket = socket;
      this.$location = $location;
      $scope.isLoading = true;
      socket.emit('GetListOfPlatforms', {
        data: '1'
      });
      socket.on('platformsFound', function(data) {
        $scope.platforms = data;
        return $scope.isLoading = false;
      });
    }

    return recommendationController;

  })());

  app.controller('searchController', searchController = (function() {
    searchController.$inject = ['$scope', '$ionicModal', 'socket', '$location'];

    function searchController($scope, $ionicModal, socket, $location) {
      var searchObject;
      this.$scope = $scope;
      this.socket = socket;
      this.$location = $location;
      $scope.myLibrary = false;
      $scope.isLoading = false;
      $scope.scoreName = 'avgscore';
      $scope.loggedin = true;
      $scope.SearchForAGame = false;
      createGameDetailViewer($ionicModal, $scope, socket);
      searchObject = $location.search();
      $scope.getGame = function() {
        $scope.isLoading = true;
        $scope.resultsFor = $scope.search;
        return socket.emit('findGamesInWiki', $scope.resultsFor);
      };
      socket.on('listOfGamesFromWiki', function(data) {
        $scope.gamesfound = [];
        if (data.results.length > 20) {
          $scope.gamesfound = data.results.slice(0, 20);
        } else {
          $scope.gamesfound = data.results;
        }
        return socket.emit('searchForGames', {
          list: $scope.gamesfound
        });
      });
      socket.on('searchfinished', function(data) {
        var item, score1, score2, _i, _len;
        $scope.games = [];
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          item = data[_i];
          if (item.details) {
            score1 = item.details.guruscore;
            score2 = item.details.peerscore;
            if (score1 && score2) {
              item.details.avgscore = (score1 * .75 + score2 * 1.25) / 2;
            } else if (score1) {
              item.details.avgscore = score1;
            } else if (score2) {
              item.details.avgscore = score2;
            }
          } else {
            item.details = {};
            item.details.avgscore = 0;
          }
          $scope.games.push(item);
        }
        $scope.setUpPages();
        return $scope.isLoading = false;
      });
      if (typeof searchObject.game !== "undefined") {
        $scope.search = searchObject.game;
        $scope.getGame();
      } else {
        $scope.SearchForAGame = true;
        $scope.isLoading = false;
      }
    }

    return searchController;

  })());

  app.controller('dashboardController', dashboardController = (function() {
    dashboardController.$inject = ['$scope', '$ionicModal', 'socket'];

    function dashboardController($scope, $ionicModal, socket) {
      this.$scope = $scope;
      this.socket = socket;
      $scope.isLoading = true;
      socket.emit('GetRecentGames');
      this.socket.on('recentReleases', function(data) {
        $scope.isLoading = false;
        return $scope.recentGames = data;
      });
      this.socket.on('noGames', function() {
        $scope.isLoading = false;
        return $scope.recentGames = false;
      });
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return dashboardController;

  })());

  app.controller('confidantController', confidantController = (function() {
    confidantController.$inject = ['$scope', '$ionicModal', 'socket', '$location'];

    function confidantController($scope, $ionicModal, socket, $location) {
      this.$scope = $scope;
      this.socket = socket;
      this.$location = $location;
      socket.emit('GetConfidants');
      $scope.getGameStyle = function(picturename) {
        return {
          'background': 'url("images/' + picturename + '")',
          'background-size': '100% 100%%   ',
          'background-repeat': 'no-repeat',
          'background-position': 'center'
        };
      };
      $scope.isLoading = true;
      $scope.confidantSelected = false;
      socket.on('listOfFriends', function(data) {
        $scope.myConfidants = data;
        return $scope.isLoading = false;
      });
      socket.on('noFriendsFound', function(data) {
        return $scope.isLoading = false;
      });
      socket.on('noUsersFound', function() {
        $scope.noneFound = true;
        return $scope.isLoadingAdder = false;
      });
      socket.on('listofPossibleConfidants', function(data) {
        $scope.confidantsFound = data;
        $scope.noneFound = false;
        return $scope.isLoadingAdder = false;
      });
      $ionicModal.fromTemplateUrl('views/addConfidantModal.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        $scope.modal = modal;
        $scope.newConfidant = {};
        $scope.selectConfidant = function(confidant) {
          $scope.confidantSelected = true;
          $scope.canFlip = 'flip';
          return $scope.newConfidant = confidant;
        };
        $scope.goback = function() {
          $scope.confidantSelected = false;
          $scope.canFlip = 'false';
          return $scope.newConfidant = {};
        };
        $scope.closeModal = function() {
          return $scope.modal.hide();
        };
        $scope.findConfidant = function(requirements) {
          var data;
          data = {
            search: requirements
          };
          $scope.isLoadingAdder = true;
          return socket.emit('SearchForConfidants', data);
        };
        $scope.addConfidant = function() {
          var data;
          data = {
            friendid: $scope.newConfidant.id
          };
          socket.emit('AddConfidant', data);
          return $scope.modal.hide();
        };
        return $scope.showConfidantAdder = function() {
          return $scope.modal.show();
        };
      });
    }

    return confidantController;

  })());

  app.controller('peerController', peerController = (function() {
    peerController.$inject = ['$scope', '$ionicModal', 'socket', '$location'];

    function peerController($scope, $ionicModal, socket, $location) {
      var searchObject;
      this.$scope = $scope;
      this.socket = socket;
      this.$location = $location;
      $scope.myLibrary = false;
      $scope.scoreName = 'avgscore';
      $scope.isLoading = true;
      searchObject = $location.search();
      socket.emit('GetListOfPlatforms', {
        data: '1'
      });
      socket.on('platformsFound', function(data) {
        return $scope.platforms = data;
      });
      $scope.currentPlatform = searchObject.platform;
      socket.emit('GetPeerLibrary', searchObject.platform);
      this.socket.on('peerLibraryFound', function(data) {
        var item, score1, score2, _i, _len, _ref;
        $scope.games = [];
        _ref = data[0];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          score1 = item.guruscore;
          score2 = item.peerscore;
          if (score1 && score2) {
            item.avgscore = (score1 * .75 + score2 * 1.25) / 2;
          } else if (score1) {
            item.avgscore = score1;
          } else if (score2) {
            item.avgscore = score2;
          }
          $scope.games.push(item);
        }
        $scope.setUpPages();
        return $scope.isLoading = false;
      });
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return peerController;

  })());

  app.controller('guruController', guruController = (function() {
    guruController.$inject = ['$scope', '$ionicModal', 'socket', '$location'];

    function guruController($scope, $ionicModal, socket, $location) {
      var searchObject;
      this.$scope = $scope;
      this.socket = socket;
      this.$location = $location;
      $scope.myLibrary = false;
      $scope.scoreName = 'avgscore';
      $scope.isLoading = true;
      searchObject = $location.search();
      socket.emit('GetListOfPlatforms', {
        data: '1'
      });
      $scope.updatePlatform = function(newPlatform) {
        $scope.isLoading = true;
        socket.emit('GetGuruLibrary', newPlatform);
        return $scope.currentPlatform = newPlatform;
      };
      socket.on('platformsFound', function(data) {
        return $scope.platforms = data;
      });
      $scope.updatePlatform(searchObject.platform);
      this.socket.on('guruLibraryFound', function(data) {
        var item, score1, score2, _i, _len, _ref;
        $scope.games = [];
        _ref = data[0];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          score1 = item.guruscore;
          score2 = item.peerscore;
          if (score1 && score2) {
            item.avgscore = (score1 * .75 + score2 * 1.25) / 2;
          } else if (score1) {
            item.avgscore = score1;
          } else if (score2) {
            item.avgscore = score2;
          }
          $scope.games.push(item);
        }
        $scope.setUpPages();
        return $scope.isLoading = false;
      });
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return guruController;

  })());

  app.controller('genericController', genericController = (function() {
    genericController.$inject = ['$scope'];

    function genericController($scope) {
      this.$scope = $scope;
      $scope.contact = false;
    }

    return genericController;

  })());

  app.controller('libraryController', libraryController = (function() {
    libraryController.$inject = ['$scope', '$ionicModal', 'socket', '$location', '$ionicPopover'];

    function libraryController($scope, $ionicModal, socket, $location, $ionicPopover) {
      var path;
      this.$scope = $scope;
      this.socket = socket;
      this.$location = $location;
      $scope.loggedin = true;
      $scope.myLibrary = true;
      $scope.NoLibraryError = false;
      $scope.scoreName = 'rating';
      $scope.gameSelected = false;
      $scope.isLoading = true;
      $scope.editMode = false;
      $scope.saveLibraryEdit = function() {
        socket.emit('UpdateUserLibraryInfo', $scope.user);
        return $scope.editMode = false;
      };
      $scope.toggleEditMode = function() {
        return $scope.editMode = !$scope.editMode;
      };
      path = $location.path();
      path = path.substring(1);
      $scope.Username = path;
      socket.emit('GetLibrary', path);
      this.socket.on('init', function(data) {});
      this.socket.on('noLibraryFound', function(data) {
        return $scope.NoLibraryError = true;
      });
      this.socket.on('gameLibraryFound', function(data) {
        var item, score1, score2, _i, _len, _ref;
        $scope.localLibrary = data.myLibrary;
        $scope.user = data.user[0];
        $scope.games = [];
        _ref = data.games;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          score1 = item.guruscore;
          score2 = item.peerscore;
          if (score1 && score2) {
            item.avgscore = (score1 * .75 + score2 * 1.25) / 2;
          } else if (score1) {
            item.avgscore = score1;
          } else if (score2) {
            item.avgscore = score2;
          }
          $scope.games.push(item);
        }
        $scope.setUpPages();
        return $scope.isLoading = false;
      });
      $ionicModal.fromTemplateUrl('views/addGameModal.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        $scope.modal = modal;
        return $scope.modalGame = {};
      });
      $scope.searchForAGame = function(game) {
        $scope.isLoadingAdder = true;
        return socket.emit('findGamesInWiki', game);
      };
      socket.on('listOfGamesFromWiki', function(data) {
        $scope.gamesfound = [];
        if (data.results.length > 20) {
          $scope.gamesfound = data.results.slice(0, 20);
        } else {
          $scope.gamesfound = data.results;
        }
        return $scope.isLoadingAdder = false;
      });
      $scope.addNewGame = function() {
        $scope.modal.show();
        $scope.canFlip = 'false';
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
        $scope.canFlip = 'flip';
        $scope.newgame.userInfo = {};
        $scope.newgame.giantBombinfo = {};
        $scope.newgame.giantBombinfo.giantBomb_id = game.id;
        $scope.newgame.giantBombinfo.game_name = game.name;
        $scope.newgame.giantBombinfo.game_picture = game.image.medium_url;
        $scope.newgame.giantBombinfo.description = game.deck;
        $scope.newgame.platforms = game.platforms;
        $scope.newgame.userInfo.rating = 3;
        $scope.newgame.userInfo.enjoyment = 3;
        $scope.newgame.userInfo.length = 3;
        $scope.newgame.userInfo.unenjoyment = 3;
        $scope.newgame.userInfo.difficulty = 3;
        return $scope.gameSelected = true;
      };
      $scope.importFromSteam = function() {
        $scope.vanity = {};
        return $ionicModal.fromTemplateUrl('views/steamImportModal.html', {
          scope: $scope,
          animation: 'slide-in-up'
        }).then(function(modal) {
          $scope.importModal = modal;
          $scope.importModal.show();
          $scope.importMode = true;
          $scope.isTransfering = true;
          $scope.vanityErrorMessage = false;
          $scope.closeImportModal = function() {
            return $scope.importModal.hide();
          };
          return $scope.getGamesFromSteam = function() {
            $scope.importMode = false;
            return socket.emit('importGamesFromSteam', $scope.vanity);
          };
        });
      };
      socket.on('steamGamesToAdd', function(data) {
        $scope.isTransfering = false;
        return $scope.newSteamGames = data;
      });
      socket.on('vanityNameNotFound', function(data) {
        $scope.isTransfering = false;
        return $scope.vanityErrorMessage = 'Vanity name is not found on steam';
      });
      $scope.goback = function() {
        $scope.canFlip = 'false';
        return $scope.gameSelected = false;
      };
      $scope.saveGame = function() {
        socket.emit('AddNewGameToLibrary', $scope.newgame);
        return $scope.closeModal();
      };
      $ionicModal.fromTemplateUrl('views/detailsLibraryModal.html', {
        scope: $scope,
        animation: 'slide-in-up'
      }).then(function(modal) {
        return $scope.detailsModal = modal;
      });
      $scope.closeLibraryDetails = function() {
        return $scope.detailsModal.hide();
      };
      $scope.getGameDetails = function(game) {
        $scope.gamedetails = game;
        $scope.gamedetails.reviewLink = $location.absUrl();
        return $scope.detailsModal.show();
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
        $scope.editingindex = index;
        return $scope.editModal.show();
      };
      $scope.showRemove = function(index) {
        var template;
        $scope.editingindex = index;
        $ionicPopover.fromTemplateUrl('my-popover.html', {
          scope: $scope
        }).then(function(popover) {
          return $scope.popover = popover;
        });
        template = '<ion-popover-view><ion-header-bar> <h1 class="title">Delete game</h1> </ion-header-bar> <ion-content> Are you sure you want to delete this game? <br/> <button ng-click="deleteGame() class="button-modal button"> Yes</button> <button ng-click="removePopover() class="button-modal assertive">No</button> </ion-content></ion-popover-view>';
        $scope.popover = $ionicPopover.fromTemplate(template, {
          scope: $scope
        });
        return $scope.popover.show();
      };
      $scope.removePopover = function() {
        return $scope.popover.hide();
      };
      $scope.$on('popover.hidden', function() {
        return $scope.popover.remove();
      });
      $scope.deleteGame = function() {
        socket.emit('deleteGame', $scope.games[$scope.editingindex]);
        return $scope.popover.hide();
      };
      $scope.updateGame = function() {
        $scope.games[$scope.editingindex] = $scope.edit;
        socket.emit('updateGame', $scope.edit);
        return $scope.editModal.hide();
      };
      createGameDetailViewer($ionicModal, $scope, socket);
    }

    return libraryController;

  })());

}).call(this);
