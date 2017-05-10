# using template for clustering
# https://blog.codeship.com/running-node-js-linux-systemd/

# using systemd socket instead of port
# https://github.com/rubenv/node-systemd/issues/12

fs = require "fs-extra"


{run} = require "./helper"
genCfg = require "./genCfg"

p = (name, type, custom) ->
  if custom
    custom + ".#{type}"
  else
    "/etc/systemd/system/#{name}.#{type}"



module.exports = (cfg) ->
  {log, echo} = require("./log")(cfg.silent)
  log "setting up systemd"
  customPath = cfg.paths?.systemd
  if not cfg.force and fs.existsSync((name = p(cfg.name,"service",customPath)))
    log "systemd", "found service in #{name}"
    log "systemd", "cancel setup"
    return
  
  genCfg = genCfg.use(cfg)
  genCfg.byDefault 
    filename: p(cfg.name,"service",customPath)
    cfgname: "systemd.service"
    objToMerge: cfg.systemd
    type: "systemd"
  if cfg.socket
    genCfg.byDefault 
      filename: p(cfg.name,"socket",customPath)
      cfgname: "systemd.socket"
      objToMerge: cfg.socket
      type: "systemd"
  unless customPath
    await run "",
      echo "systemd", "reloading daemon"
      "systemctl daemon-reload"
      echo "systemd", "starting #{cfg.name}"
      "systemctl start #{cfg.name}"
      echo "systemd", "enabling #{cfg.name}"
      "systemctl enable #{cfg.name}"
    