module.exports = (cfg, options) ->  
  listen: 80
  server_name: if options then options else cfg.domains?.join " "
  "location /":
    proxy_set_header: "Upgrade $http_upgrade"
    proxy_set_header: "Connection \"upgrade\""
    proxy_http_version: "1.1"
    proxy_set_header: "X-Forwarded-For $proxy_add_x_forwarded_for"
    proxy_set_header: "Host $host"
    proxy_pass: if cfg.socket then "http://unix:/run/#{cfg.name}.sk:/" else "http://localhost:#{cfg.port}"