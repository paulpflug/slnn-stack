module.exports = (cfg) ->
  Socket:
    ListenStream: "/run/#{cfg.name}.sk"
  Install:
    WantedBy: "sockets.target"