fs = require "fs-extra"
which = require "which"
url = require "url"
genCfg = require "./genCfg"
{isObject} = require "./helper"
p = (type, domain, custom) -> "/etc/nginx/sites-#{type}/#{domain}"
available = "available"
enabled = "enabled"



module.exports = (cfg) ->
  {log} = require("./log")(cfg.silent)
  log "setting up nginx"
  unless (customPath = cfg.paths?.nginx)
    if cfg.domains and not cfg.force
      for domain in cfg.domains.concat([cfg.name])
        if fs.existsSync(p(available,domain))
          log "nginx", "found configuration for #{domain}"
          log "nginx", "cancel setup"
          return
    try
      which.sync "nginx"
    catch 
      log "nginx", "nginx not found"
      log "nginx", "cancel setup"
      return
  else
    if fs.existsSync(customPath) and not cfg.force
      log "nginx", "found configuration in #{customPath}"
      log "nginx", "cancel setup"
      return
  cfg.domains ?= []
  genCfg = genCfg.use(cfg)
  mainHostname = null
  domains = {}
  for domain in cfg.domains
    tmp = url.parse("http://"+domain).hostname.split(".")
    tmp.shift() if tmp.length > 2
    hostname = tmp.join(".")
    mainHostname ?= hostname
    domains[hostname] ?= []
    domains[hostname].push domain
  str = ""
  toNginx = genCfg.objTo.nginx
  if not cfg.letsencrypt or # no ssl
      cfg.domains.length == 0 # no domain for ssl
    str += toNginx genCfg.mergeWithDefault 
      cfgname: "nginx.proxy"
      objToMerge: cfg.nginx.noSSL or cfg.nginx
  else # use ssl
    # enforce ssl by redirect
    str += toNginx genCfg.mergeWithDefault 
      cfgname: "nginx.301"
      objToMerge: cfg.nginx.noSSLredirect or cfg.nginx.redirect or cfg.nginx
    for hostname, ds of domains
      unless hostname == mainHostname # ssl redirect
        str += toNginx genCfg.mergeWithDefault 
          cfgname: "nginx.ssl.301"
          objToMerge: cfg.nginx.SSLredirect or cfg.nginx.redirect or cfg.nginx
          options: ds.join(" ")
      else # ssl proxy to node
        str += toNginx genCfg.mergeWithDefault 
          cfgname: "nginx.ssl.proxy"
          objToMerge: cfg.nginx.SSL or cfg.nginx
          options: ds.join(" ")
  genCfg.writeFile
    filename: customPath or p(available, cfg.name)
    content: str
    cfgname: "nginx"
  
  unless customPath
    log "nginx", "creating enabled symlink"
    await fs.ensureSymlinkSync p(available, cfg.name), p(enabled, cfg.name)
  else
    log "nginx", "please create a enabled symlink yourself"
  log "nginx", "run 'nginx -t' to test configuration"
  log "nginx", "run 'systemctl restart nginx' to apply configuration"