module.exports = (silent) ->
  if silent
    nl: ->
    log: ->
    echo: -> ":"
  else
    nl: (nr = 1) -> console.log "\n".repeat(nr)
    log: (nsp,str) ->
      unless str
        str = nsp
        nsp = ""
      if nsp
        nsp = "."+nsp
      console.log "slnn#{nsp}: #{str}"
    echo: (nsp,str) ->
      unless str
        str = nsp
        nsp = ""
      if nsp
        nsp = "."+nsp
      return "echo 'slnn#{nsp}: #{str}'" 