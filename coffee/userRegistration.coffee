#  cfcoptions : { "out": "../js/"   }
module.exports =  (client,connection, bcrypt,crypto,validator) -> 
    salt = bcrypt.genSaltSync(10);
    client.on 'SignUpUser', (data)->
        if not validator.isEmail data.username
            client.emit 'failureMessage', 'Not a valid email address'
        else if not validator.isAlphanumeric data.name
            client.emit 'failureMessage', 'Display name many only contain Letters and numbers'
        else 
            sql = 'Select Count(*) as userCount from user where username = ?'
            connection.query sql, [data.username], (err, result) ->
                if result[0].userCount >0 
                    client.emit 'failureMessage', 'That email already exists'
                else
                    sql = 'Select Count(*) as userCount from user where name =?'
                    connection.query sql, [data.name], (err, result) ->
                        if result[0].userCount >0 
                            client.emit 'failureMessage' ,'Username already exists'
                        else 
                            sql = 'Insert into user Set ?' 
                            d = new Date()
                            currentTime= d.getMilliseconds()
                            newExpiration = currentTime + 7*86400000
                            sessionKey=crypto.createHash('md5').update(currentTime+'salt').digest 'hex'
                            data.sessionKey= sessionKey
                            data.expires=newExpiration
                            data.password = bcrypt.hashSync data.password, salt;
                            connection.query sql,  data,  (err,result) ->
                                client.userid = result.insertId
                                accessList =  getAccessList false
                                client.emit 'userLoggedin', {sessionKey: sessionKey , location:'/home', accessList:accessList}
    client.on 'loginToFaceBook', (data)->
        sql = 'Select Count(*) as userCount , name, id from user where username ="'+data.email+'" and facebookkey = "' +data.id+'"'
        connection.query sql, [data.username], (err, result) ->
            if result[0].userCount > 0 
                client.userid=result[0].id
                client.username=result[0].name
                d = new Date()
                currentTime= d.getMilliseconds()
                newExpiration = currentTime + 7*86400000
                sessionKey=crypto.createHash('md5').update(currentTime+'salt').digest 'hex'
                sql = 'Update user set sessionkey ="'+sessionKey+'", expires = '+newExpiration+' where  id ='+client.userid
                accessList =  getAccessList result[0].isAdmin
                client.emit 'userLoggedin', {sessionKey: sessionKey, location:'/home', accessList:accessList }
                connection.query sql,  data.userInfo, (err,results) ->
            else 
                sqls = 'Insert into user Set ?'
                newData ={}
                newData.username= data.email
                newData.password= 'facebookuser'
                newData.facebookkey= data.id
                console.log newData
                connection.query sqls,  newData, (err,results) ->
                    client.userid = results.insertId
                    console.log client.userid
                    client.emit 'NeedUsername'
    client.on 'addUsername', (data)->
        if not validator.isAlphanumeric(data)
            client.emit 'failureMessage', 'Display name many only contain Letters and numbers'
        else
            sql ='select Count(*) as userCount  from user where name="'+data+'"'
            connection.query sql, [data.username], (err, result) ->
                if result[0].userCount >0 
                    client.emit 'failureMessage', 'That Display name already exists please try again'
                else 
                    sql = 'Update user set name ="'+data+'" where id ='+client.userid
                    connection.query sql, (err,results) ->
                        client.emit 'usernameAdded'
                        client.username= data
                        d = new Date()
                        currentTime= d.getMilliseconds()
                        newExpiration = currentTime + 7*86400000
                        sessionKey=crypto.createHash('md5').update(currentTime+'salt').digest 'hex'
                        sql = 'Update user set sessionkey ="'+sessionKey+'", expires = '+newExpiration+' where  id ='+client.userid
                        accessList =  getAccessList false
                        client.emit 'userLoggedin', {sessionKey: sessionKey, location:'/home', accessList:accessList }
                               
    updateExpirationDate = (newExperationDate) ->
        sql = 'Update user set expires ='+newExperationDate+' where  id ='+client.userid
        connection.query sql, (err, results) ->        
    
    client.on 'logout',(data)->
        updateExpirationDate 0
    
    getAccessList = (isadmin)->
        accessList = [{name:'Dashboard', link:'dashboard', icon: 'ion-ios-home-outline'},
                      {name:'Library', link:client.username, icon:'ion-ios-book-outline'},
                      {name:'Suggestions', link:'recommendations', icon:'ion-ios-people-outline'},
                      {name:'Confidants', link:'confidants', icon:'ion-person-stalker'}]
        
    client.on 'isUserLoggedin', (data)->
        d = new Date()
        currentTime= d.getMilliseconds()
        sql = 'Select * from  user where sessionkey	 = ? and expires >'+currentTime
        connection.query sql, [data.key], (err, result) ->
            if  result[0]
                newExpiration = currentTime + 7*86400000
                client.userid= result[0].id
                client.username= result[0].name
                accessList =  getAccessList result[0].isAdmin
                client.emit 'userLoggedin', {sessionKey: data.key, location:data.location, accessList:accessList}
                updateExpirationDate newExpiration
            else 
                client.emit 'failedToLogin', 0
                
    client.on 'Login', (data)->
        sql = 'Select password, isAdmin,id,name from user where username ="'+data.username+'"'
        connection.query sql, (err, result) -> 
            if result.length>0
                bcrypt.compare data.password , result[0].password, (err,res)->
                    if res
                        client.userid=result[0].id
                        client.username= result[0].name
                        d = new Date()
                        currentTime= d.getMilliseconds()
                        newExpiration = currentTime + 7*86400000
                        sessionKey=crypto.createHash('md5').update(currentTime+'salt').digest('hex')
                        sql = 'Update user set sessionkey ="'+sessionKey+'", expires = '+newExpiration+' where  id ='+client.userid
                        accessList =  getAccessList result[0].isAdmin
                        client.emit 'userLoggedin', {sessionKey: sessionKey, location:'/home', accessList:accessList }
                        connection.query sql,  data.userInfo,  (err,results) ->
                          
                    else 
                        client.emit 'failureMessage', 'Username or Password incorrect' 
            else 
                client.emit 'failureMessage', 'User not found'
