module.exports =
  manager:
    port: process.env.MANAGER_PORT || 8000
  proxy:
    port: process.env.PROXY_PORT || 8001
  secret: '*&GSD()02h0h2--ncn*AHAH98a9sa66dcfng-22'
  mongodb:
    database: 'sitebox'
    host: process.env.MONGO_HOST || '127.0.0.1'
    port: process.env.MONGO_PORT || 27017
    options: {}
  memcached:
    hosts: '127.0.0.1:11211'
  dropbox:
    app_key: 'k1exhbt2d7l977o'
    app_secret: '61p7bmsrzrmbz42'
  oauthCallback: 'http://localhost:8000/oauth/callback'
