module.exports = (cfg, options) -> 
  listen: [
    "443 http2"
    "[::]:443 http2"
    ]
  ssl: "on"
  ssl_certificate: "/etc/letsencrypt/live/#{mainDomain = cfg.domains[0]}/fullchain.pem"
  ssl_certificate_key: "/etc/letsencrypt/live/#{mainDomain}/privkey.pem"
  ssl_session_timeout: "30m"
  server_name: if options then options else cfg.domains?.join " "
  "location /":
    proxy_set_header: [
      "Upgrade $http_upgrade"
      "Connection \"upgrade\""
      "X-Forwarded-For $proxy_add_x_forwarded_for"
      "Host $host"
      ]
    proxy_http_version: "1.1"
    proxy_pass: if cfg.socket then "http://unix:/run/#{cfg.name}.sk:/" else "http://localhost:#{cfg.port}"