(function() {
  module.exports = {
    connection: '',

    /* common game adders using giantbomb info */
    getOrCreateGame: function(data, platforms, callback) {
      var curConnection, curPlatformCreator, sql;
      sql = 'Select count(*) as gamecount, id from games where giantBomb_id = ' + data.giantBomb_id;
      curConnection = this.connection;
      curPlatformCreator = this.getOrCreatePlatform;
      return curConnection.query(sql, function(err, result) {
        var firstresult;
        firstresult = result[0];
        if (firstresult.gamecount > 0) {
          return callback(firstresult.id);
        } else {
          sql = 'Insert into games Set ?';
          return curConnection.query(sql, data, function(err, result) {
            var gameid, platform, _i, _len;
            gameid = result.insertId;
            for (_i = 0, _len = platforms.length; _i < _len; _i++) {
              platform = platforms[_i];
              curPlatformCreator(platform.abbreviation, gameid, curConnection);
            }
            return callback(gameid);
          });
        }
      });
    },
    getOrCreatePlatform: function(platform, gameid, aconnection) {
      var sql;
      sql = 'Select count(*) as gamecount, id from platforms where active=1 and name = "' + platform + '"';
      return aconnection.query(sql, function(err, result) {
        var firstresult;
        firstresult = result[0];
        if (firstresult.gamecount > 0) {
          return this.addPlatformTogame(firstresult.id, gameid, aconnection);
        } else {
          return 1;
        }
      });
    },
    addPlatformTogame: function(platformid, gameid, aconnection) {
      var gameinfo, sql;
      gameinfo = {
        game_id: gameid,
        platform_id: platformid
      };
      sql = 'insert into  gameOnplatform  Set ? ';
      return aconnection.query(sql, gameinfo, function(err, result) {});
    }
  };

}).call(this);
