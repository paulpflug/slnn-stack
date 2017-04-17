which = require "which"
{resolve} = require "path"

module.exports = (cfg) ->
  Unit:
    Description:  cfg.name
  Service:
    ExecStart: "#{which.sync('node')} #{resolve(cfg.main)}"
    WorkingDirectory: cfg.folder
    Restart: "always"
    StandardOutput: "syslog"
    StandardError: "syslog"
    SyslogIdentifier:  cfg.name
    Environment: "NODE_ENV=production"
  Install:
    WantedBy: "multi-user.target"