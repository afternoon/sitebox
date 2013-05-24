dbox = require 'dbox'
connect = require 'connect'
http = require 'http'

conf = require './conf'
mongohelpers = require './mongohelpers'
sites = require './siterepository'
dboxfiles = require './dboxfilerepository'

extractDomain = (host) -> host.split(':').shift()

extractPath = (url) ->
  path = url.split(/[?#]/).shift()
  if path == '/' then '/index.html' else path

mongohelpers.withMongoDb (error, mongoClient) ->
  dropbox = dbox.app conf.dropbox
  siteRepo = new sites.SiteRepository mongoClient

  app = connect()
  app.use connect.logger('dev')

  app.use (req, res) ->
    domain = extractDomain req.headers.host
    path = extractPath req.url
    siteRepo.findOne domain: domain, (error, site) ->
      fileRepo = new dboxfiles.DboxFileRepository dropbox, site.accessToken
      fileRepo.get "/#{domain}#{path}", res

  server = http.createServer(app)
  server.listen conf.proxy.port, ->
    console.log 'Sitebox proxy app listening on port ' + conf.proxy.port
