which = require "which"
{run} = require "./helper"
fs = require "fs"
# https://certbot.eff.org/#ubuntuxenial-nginx
p = (domain) -> "/etc/letsencrypt/live/#{domain}"
module.exports = (cfg) ->
  {log, echo} = require("./log")(cfg.silent)
  log "setting up letsencrypt"
  unless cfg.domains
    log "letsencrypt", "no domains provided"
    log "letsencrypt", "cancel setup"
    return
  for domain, i in cfg.domains
    if fs.existsSync(p(domain))
      log "letsencrypt", "found cert for #{domain}"
      if i != 0
        log "letsencrypt", "you have to point nginx configuration to #{p(domain)} yourself, as #{cfg.domains[0]} is set as default domain."
      log "letsencrypt", "cancel setup"
      return
  try
    which.sync "certbot"
  catch 
    log "letsencrypt", "certbot not found"
    log "letsencrypt", "cancel setup"
    return
  domains = cfg.domains.map((d) -> "-d #{d}").join(" ")
  await run "",
    "systemctl stop nginx"
    echo "letsencrypt", "getting certificates"
    "certbot certonly --standalone -n --agree-tos #{domains} --renew-hook 'systemctl restart nginx'"
    "systemctl start nginx"
    #echo "letsencrypt", "setting up renew"
    #"certbot renew -n '"