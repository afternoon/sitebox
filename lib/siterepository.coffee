mongodb = require 'mongodb'

class SiteRepository
  constructor: (@mongoClient) ->
    @coll = new mongodb.Collection(@mongoClient, 'sites')

  add: (site, cb) ->
    @coll.insert site, cb

  find: (query, cb) ->
    @coll
      .find(query)
      .toArray(cb)

  findOne: (query, cb) ->
    @coll.findOne query, cb

module.exports = {SiteRepository}
