module.exports = (cfg, options) ->
  listen: ["80","[::]:80"]
  server_name: if options then options else cfg.domains.join " "
  return: "301 https://#{cfg.domains[0]}$request_uri"