module.exports = (cfg, options) ->
  listen: 443
  ssl: "on"
  ssl_certificate: "/etc/letsencrypt/live/#{mainDomain = cfg.domains[0]}/fullchain.pem"
  ssl_certificate_key: "/etc/letsencrypt/live/#{mainDomain}/privkey.pem"
  ssl_session_timeout: "30m"
  server_name: if options then options else cfg.domains.slice(1).join " "
  return: "301 https://#{mainDomain}$request_uri"