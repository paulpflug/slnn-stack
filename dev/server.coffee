Koa = require("koa")
module.exports = (server, reload) =>
  Locale = require("../src/getLocale.coffee")
  locale = new Locale
    supported: ["de","en"]
  koa = new Koa
  koa.use locale.middleware "koa"
  server.on "request", koa.callback()
  server.listen 8080
  return =>