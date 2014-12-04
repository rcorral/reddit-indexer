http = require 'http'
https = require 'https'
moment = require 'moment'
packageInfo = require './package.json'
Promise = require 'promise'

getHotPosts = (count) ->
    new Promise (resolve, reject) ->
        opts =
            hostname: 'www.reddit.com'
            port: 443
            path: "/r/all/hot.json?limit=#{count}"
            headers:
                'User-Agent': "reddit-indexer/#{packageInfo.version} by @rcorral"

        req = https.get opts, (res) ->
            response = ''
            res.setEncoding 'utf8'

            res.on 'data', (data) ->
                response += data

            res.on 'end', ->
                console.log 'Got posts.'
                resolve JSON.parse response

        .on 'error', (e) ->
            reject 'problem with request: ' + e.message

        req.end()

storePosts = (posts) ->
    new Promise (resolve, reject) ->
        for post, i in posts.data.children
            do (post, i, posts) ->
                postData = post.data
                opts =
                    hostname: 'localhost'
                    port: 9200
                    path: "/reddit/post/#{postData.name}"
                    method: 'PUT'

                req = http.request opts, (res) ->
                    response = ''
                    res.setEncoding 'utf8'

                    res.on 'data', (data) ->
                        response += data

                    res.on 'end', ->
                        response = JSON.parse response

                        if not response._id
                            reject 'Post did not save.'
                        else if i + 1 is posts.data.children.length
                            console.log 'Posts saved.'
                            resolve()

                .on 'error', (e) ->
                    reject 'problem with request: ' + e.message

                req.write JSON.stringify postData
                req.end()

queueNextRequest = ->
    # Setting the hour to 24 will also change the day
    hours = [6, 12, 18, 24]
    now = moment()
    for hour in hours
        if now.hour() < hour
            next = now.hour hour
            now = moment()
            break

    # Reset, just so it's always on the hour
    next.minute(0).second(0).millisecond(0)

    setTimeout begin, next.diff now
    console.log "Queued next request for: #{next.toString()}"

begin = ->
    getHotPosts(50)
    .then storePosts
    .then queueNextRequest
    .catch -> console.error arguments...

begin()
