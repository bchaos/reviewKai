(function() {
  module.exports = function(client, connection, bcrypt, crypto, validator) {
    var getAccessList, salt, updateExpirationDate;
    salt = bcrypt.genSaltSync(10);
    client.on('SignUpUser', function(data) {
      var sql;
      if (!validator.isEmail(data.username)) {
        return client.emit('failureMessage', 'Not a valid email address');
      } else if (!validator.isAlphanumeric(data.name)) {
        return client.emit('failureMessage', 'Display name many only contain Letters and numbers');
      } else {
        sql = 'Select Count(*) as userCount from user where username = ?';
        return connection.query(sql, [data.username], function(err, result) {
          if (result[0].userCount > 0) {
            return client.emit('failureMessage', 'That email already exists');
          } else {
            sql = 'Select Count(*) as userCount from user where name =?';
            return connection.query(sql, [data.name], function(err, result) {
              var currentTime, d, newExpiration, sessionKey;
              if (result[0].userCount > 0) {
                return client.emit('failureMessage', 'Username already exists');
              } else {
                sql = 'Insert into user Set ?';
                d = new Date();
                currentTime = d.getMilliseconds();
                newExpiration = currentTime + 7 * 86400000;
                sessionKey = crypto.createHash('md5').update(currentTime + 'salt').digest('hex');
                data.sessionKey = sessionKey;
                data.expires = newExpiration;
                data.password = bcrypt.hashSync(data.password, salt);
                return connection.query(sql, data, function(err, result) {
                  var accessList;
                  client.userid = result.insertId;
                  accessList = getAccessList(false);
                  return client.emit('userLoggedin', {
                    sessionKey: sessionKey,
                    location: '/home',
                    accessList: accessList
                  });
                });
              }
            });
          }
        });
      }
    });
    client.on('loginToFaceBook', function(data) {
      var sql;
      sql = 'Select Count(*) as userCount , name, id from user where username ="' + data.email + '" and facebookkey = "' + data.id + '"';
      return connection.query(sql, [data.username], function(err, result) {
        var accessList, currentTime, d, newData, newExpiration, sessionKey, sqls;
        if (result[0].userCount > 0) {
          client.userid = result[0].id;
          client.username = result[0].name;
          d = new Date();
          currentTime = d.getMilliseconds();
          newExpiration = currentTime + 7 * 86400000;
          sessionKey = crypto.createHash('md5').update(currentTime + 'salt').digest('hex');
          sql = 'Update user set sessionkey ="' + sessionKey + '", expires = ' + newExpiration + ' where  id =' + client.userid;
          accessList = getAccessList(result[0].isAdmin);
          client.emit('userLoggedin', {
            sessionKey: sessionKey,
            location: '/home',
            accessList: accessList
          });
          return connection.query(sql, data.userInfo, function(err, results) {});
        } else {
          sqls = 'Insert into user Set ?';
          newData = {};
          newData.username = data.email;
          newData.password = 'facebookuser';
          newData.facebookkey = data.id;
          console.log(newData);
          return connection.query(sqls, newData, function(err, results) {
            client.userid = results.insertId;
            console.log(client.userid);
            return client.emit('NeedUsername');
          });
        }
      });
    });
    client.on('addUsername', function(data) {
      var sql;
      if (!validator.isAlphanumeric(data)) {
        return client.emit('failureMessage', 'Display name many only contain Letters and numbers');
      } else {
        sql = 'select Count(*) as userCount  from user where name="' + data + '"';
        return connection.query(sql, [data.username], function(err, result) {
          if (result[0].userCount > 0) {
            return client.emit('failureMessage', 'That Display name already exists please try again');
          } else {
            sql = 'Update user set name ="' + data + '" where id =' + client.userid;
            return connection.query(sql, function(err, results) {
              var accessList, currentTime, d, newExpiration, sessionKey;
              client.emit('usernameAdded');
              client.username = data;
              d = new Date();
              currentTime = d.getMilliseconds();
              newExpiration = currentTime + 7 * 86400000;
              sessionKey = crypto.createHash('md5').update(currentTime + 'salt').digest('hex');
              sql = 'Update user set sessionkey ="' + sessionKey + '", expires = ' + newExpiration + ' where  id =' + client.userid;
              accessList = getAccessList(false);
              return client.emit('userLoggedin', {
                sessionKey: sessionKey,
                location: '/home',
                accessList: accessList
              });
            });
          }
        });
      }
    });
    updateExpirationDate = function(newExperationDate) {
      var sql;
      sql = 'Update user set expires =' + newExperationDate + ' where  id =' + client.userid;
      return connection.query(sql, function(err, results) {});
    };
    client.on('logout', function(data) {
      return updateExpirationDate(0);
    });
    getAccessList = function(isadmin) {
      var accessList;
      return accessList = [
        {
          name: 'Dashboard',
          link: 'dashboard',
          icon: 'ion-ios-home-outline'
        }, {
          name: 'Library',
          link: client.username,
          icon: 'ion-ios-book-outline'
        }, {
          name: 'Suggestions',
          link: 'recommendations',
          icon: 'ion-ios-people-outline'
        }, {
          name: 'Confidants',
          link: 'confidants',
          icon: 'ion-person-stalker'
        }
      ];
    };
    client.on('isUserLoggedin', function(data) {
      var currentTime, d, sql;
      d = new Date();
      currentTime = d.getMilliseconds();
      sql = 'Select * from  user where sessionkey	 = ? and expires >' + currentTime;
      return connection.query(sql, [data.key], function(err, result) {
        var accessList, newExpiration;
        if (result[0]) {
          newExpiration = currentTime + 7 * 86400000;
          client.userid = result[0].id;
          client.username = result[0].name;
          accessList = getAccessList(result[0].isAdmin);
          client.emit('userLoggedin', {
            sessionKey: data.key,
            location: data.location,
            accessList: accessList
          });
          return updateExpirationDate(newExpiration);
        } else {
          return client.emit('failedToLogin', 0);
        }
      });
    });
    return client.on('Login', function(data) {
      var sql;
      sql = 'Select password, isAdmin,id,name from user where username ="' + data.username + '"';
      return connection.query(sql, function(err, result) {
        if (result.length > 0) {
          return bcrypt.compare(data.password, result[0].password, function(err, res) {
            var accessList, currentTime, d, newExpiration, sessionKey;
            if (res) {
              client.userid = result[0].id;
              client.username = result[0].name;
              d = new Date();
              currentTime = d.getMilliseconds();
              newExpiration = currentTime + 7 * 86400000;
              sessionKey = crypto.createHash('md5').update(currentTime + 'salt').digest('hex');
              sql = 'Update user set sessionkey ="' + sessionKey + '", expires = ' + newExpiration + ' where  id =' + client.userid;
              accessList = getAccessList(result[0].isAdmin);
              client.emit('userLoggedin', {
                sessionKey: sessionKey,
                location: '/home',
                accessList: accessList
              });
              return connection.query(sql, data.userInfo, function(err, results) {});
            } else {
              return client.emit('failureMessage', 'Username or Password incorrect');
            }
          });
        } else {
          return client.emit('failureMessage', 'User not found');
        }
      });
    });
  };

}).call(this);
