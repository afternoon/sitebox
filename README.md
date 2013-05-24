Sitebox
=======

Dropbox-powered websites with custom domains.

Requirements
------------

- mongodb
- memcached

Run
---

- Start mongod and memcached
- Create `lib/conf.coffee` (use `lib/conf.coffee.example` as a starting point)
- Run `npm run manager` to start the management application (sign in with
  Dropbox, add sites)
- Run `npm run proxy` to start the proxy application, which serves files from
  Dropbox
