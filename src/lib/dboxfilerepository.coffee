# file repositories store sites and provide access to files
# DropboxFileRepository uses dbox as a backend
class DboxFileRepository
  constructor: (@dropbox, @accessToken) ->
    @client = dropbox.client(@accessToken)

  add: (site, cb) ->
    @client.mkdir '/' + site, {}, cb

  # list available sites
  find: (cb) ->
    @client.readdir '/', (status, reply) ->
      if status == 200
        # reply is like ['/', '/site1.com', '/site2.com']
        sites = reply
          .map((s) -> s.slice(1))
          .filter((s) -> s.indexOf('.') != -1)
        cb(undefined, sites)
      else
        cb(status, undefined)

  get: (filepath, res) ->
    @client.get filepath, (status, reply, metadata) ->
      res.setHeader 'Content-Type', metadata.mime_type
      res.setHeader 'Content-Length', metadata.bytes
      res.setHeader 'Date', metadata.modified
      res.setHeader 'Last-Modified', metadata.modified
      res.end reply

module.exports = {DboxFileRepository}
