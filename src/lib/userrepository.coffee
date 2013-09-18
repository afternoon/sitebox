mongodb = require 'mongodb'

class UserRepository
  constructor: (mongoClient) ->
    @coll = new mongodb.Collection(mongoClient, 'users')

  add: (user) ->
    @coll.insert user

  find: (username) ->
    @coll.find username: username

module.exports = {UserRepository}
