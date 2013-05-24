dbox = require 'dbox'
express = require 'express'
http = require 'http'
MemcachedStore = require('connect-memcached')(express)
path = require 'path'

conf = require './conf'
mongohelpers = require './mongohelpers'
sites = require './siterepository'
users = require './userrepository'
dboxfiles = require './dboxfilerepository'

domainRe = /(\w+\.)+\w+/

isDomain = (d) -> domainRe.test d

configureApp = ->
  app = express()
  app.set 'views', path.join __dirname, '..', 'views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session
    secret: conf.secret
    store: new MemcachedStore(hosts: conf.memcached.hosts)
  app.use express.static path.join __dirname, '..', 'public'
  if app.get('env') == 'development'
    app.use express.errorHandler()
    app.use express.logger('dev')
  else
    app.use express.logger()
  app.use app.router
  app

requireUser = (handler) ->
  (req, res) ->
    if req.session.user
      handler req, res
    else
      res.redirect '/'

buildApp = (dropbox, userRepo, siteRepo) ->
  app = configureApp()

  # home page
  app.get '/', (req, res) -> res.render 'index'

  # start oauth signin process
  app.get '/oauth/signin', (req, res) ->
    dropbox.requesttoken (status, requestToken) ->
      if status == 200
        req.session.user = requestToken: requestToken
        authUrl = requestToken.authorize_url
        callback = conf.oauthCallback
        res.redirect "#{authUrl}&oauth_callback=#{callback}"
      else
        error = "Dropbox did not provide a request token (status #{status})"
        throw new Error(error)

  # complete oauth signin
  app.get '/oauth/callback', (req, res) ->
    if req.session.user
      requestToken = req.session.user.requestToken
      dropbox.accesstoken requestToken, (status, accessToken) ->
        if status == 200
          req.session.user.accessToken = accessToken
          dropboxClient = dropbox.client(accessToken)
          dropboxClient.account (status, reply) ->
            if status == 200
              req.session.user.id = reply.uid
              userRepo.add
                uid: reply.uid
                email: reply.email
                accessToken: accessToken
              res.redirect '/dashboard'
            else
              throw new Error("Dropbox error #{reply} (#{status})")
        else
          error = "Dropbox did not provide an access token (status #{status})"
          throw new Error(error)
    else
      res.redirect '/'

  # dashboard
  app.get '/dashboard', requireUser (req, res) ->
    siteRepo.find user: req.session.user.id, (error, sites) ->
      res.render 'dashboard', {sites}

  # add site form
  app.get '/add', requireUser (req, res) ->
    res.render 'add'

  # add site submit
  app.post '/add', requireUser (req, res) ->
    if isDomain(req.body.domain)
      console.log 'isDomain'
      site =
        user: req.session.user.id
        accessToken: req.session.user.accessToken
        domain: req.body.domain.replace 'www.', ''
      siteRepo.add site, (error, docs) ->
        fileRepo = new dboxfiles.DboxFileRepository dropbox,
          req.session.user.accessToken
        fileRepo.add site.domain, (status, reply) ->
          res.redirect '/dashboard', 303
    else
      throw new Error("#{req.body.domain} is not a valid domain name")

start = (app) ->
  server = http.createServer(app)
  server.listen conf.manager.port, ->
    console.log 'Sitebox management app listening on port ' + conf.manager.port

mongohelpers.withMongoDb (error, mongoClient) ->
  dropbox = dbox.app conf.dropbox
  userRepo = new users.UserRepository mongoClient
  siteRepo = new sites.SiteRepository mongoClient
  app = buildApp(dropbox, userRepo, siteRepo)

  start app
