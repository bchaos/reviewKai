#  cfcoptions : { "out": "../js/"   }
module.exports =  (client,ss,connection,fs) ->

    getCurrentPicture=   (callback)->
        sql = 'select picture from user where user.id = ' + client.userid
        connection.query sql, (err, result) ->
            callback result[0].picture

    updatePicture= (name,callback)->
        sql = 'update user set picure ="'+name+'" where userid = ' + client.userid
        connection.query sql, (err, result) ->
            callback 'updated'

    deleteOldPicture = (pathToPic)->
        fs.unlinkSync(pathToPic)

    ss(client).on 'newProfileImage', (stream, data) ->
        baseUploadPath = './../images/userimages/'
        baseFilename = client.username+'_'+data.name

        newFilename = baseUploadPath+baseFilename
        console.log newFilename
        stream.pipe(fs.createWriteStream(newFilename))
        getCurrentPicture (pic)->
            if pic isnt 'rkdefault.png'
                deleteOldPicture baseUploadPath+pic

            updatePicture baseFilename, ->
                client.emit 'pictureUpdated' ,baseFilename
