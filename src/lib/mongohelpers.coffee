mongodb = require 'mongodb'

conf = require "./conf"

withMongoDb = (onSuccess) ->
  server = new mongodb.Server conf.mongodb.host,
    conf.mongodb.port,
    conf.mongodb.options
  client = new mongodb.Db conf.mongodb.database, server, safe: false
  client.open onSuccess

module.exports = {withMongoDb}
