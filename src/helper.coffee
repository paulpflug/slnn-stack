path = require "path"
runner = require "script-runner"
fs = require "fs-extra"
run = (folder, cmds...) -> new Promise (resolve, reject) ->
  runner [units:cmds.map((cmd)-> cmd: "cd #{folder} && #{cmd}")],{}, (exitcode) ->
    return reject(exitcode) if exitcode
    resolve()
module.exports =
  run: run
  get:
    cwd: (str) ->
      if (str == true and str = ".") or str
        return path.resolve(str)
      return false
    postReceive: (folder) -> path.resolve folder, ".git/hooks/post-receive"
    relativeToHome: (folder) -> path.relative(require('os').homedir(), folder)
  gitInit: (folder) ->
    unless fs.existsSync path.resolve(folder,".git")
      await run folder, "git init -q"
  getCfg: (folder) ->
    try
      cfg = require path.resolve(folder, "./slnn")
      cfg.folder = folder
      return cfg
    catch e
      console.log e
      throw new Error "no slnn file found in #{folder}"
  isObject: (val) -> val? and typeof val == "object" and not Array.isArray(val)