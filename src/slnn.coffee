fs = require "fs-extra"
path = require "path"
genCfg = require "./genCfg"
ip = require "ip"
try
  require "coffeescript/register"
catch
  try
    require "coffee-script/register"

{run, get,gitInit,getCfg} = require "./helper"

postReceive = (folder) -> ".git/hooks/post-receive"

module.exports = (program) ->
  program.cwd ?= true
  if folder = get.cwd(program.init)
    {log,echo, nl} = require("./log")(program.silent)
    nl 2
    log "INIT"
    log "initing #{folder}"
    fs.mkdirsSync folder
    await gitInit(folder)
    postReceive = get.postReceive(folder)
    genCfg.byTemplate 
      filename: postReceive
      cfgname: "git.init"
    await run "", "chmod +x #{postReceive}"
    user = process.env.USER
    log """init done. Run on client side: slnn deploy ssh://#{user}@#{ip.address()}/~/#{get.relativeToHome(folder)}"""

  else if folder = get.cwd(program.setup)
    cfg = getCfg folder
    cfg.silent ?= program.silent
    {log,echo, nl} = require("./log")(cfg.silent)
    nl 2
    log "SETUP"
    log "setting up stack in #{folder}"
    
    cfg.folder = folder
    postReceive = get.postReceive(folder)
    genCfg.byTemplate 
      filename: postReceive
      cfgname: "git"
      cfg: cfg
    await run "", "chmod +x #{postReceive}"
    for name in ["letsencrypt","nginx","systemd"]
      if cfg[name]
        await require("./#{name}")(cfg)
          .catch (e) -> 
            console.error e
            log "setup of #{name} failed"
            log "you can manually call slnn setup in the project folder"
            log "maybe you need root rights"
    # not remote setup
    await run folder, 
      "if grep -q 'master' .git/HEAD ; then #{echo('npm install')} && npm install --production && #{echo('restart service')} && systemctl restart #{cfg.name}; fi"
  else if (gitpath = program.deploy) and (folder = get.cwd(program.cwd))
    cfg = getCfg folder
    cfg.silent ?= program.silent
    {log,echo, nl} = require("./log")(cfg.silent)
    nl 2
    log "DEPLOY"
    unless cfg.deploy
      throw new Error "no deploy folder specified in slnn file"
    deployFolder = path.resolve folder, cfg.deploy
    getCfg deployFolder
    await gitInit deployFolder
    if gitpath && gitpath != true
      await run deployFolder, 
        "#{echo('setting up remote url')}"
        "git remote add slnn #{gitpath} || git remote set-url slnn #{gitpath}"
    await run deployFolder, 
      "#{echo('checkout clientside branch')}",
      "git checkout -q -b clientside || git checkout -q clientside",
      "git add .",
      "#{echo('commit all changes')}",
      "git commit -q -m 'clientside' || true",
      "#{echo('push clientside branch')}",
      "git push -q slnn clientside",
      "#{echo('checkout master branch')}"
      "git checkout -q  master || git checkout -q  -b master"
      "#{echo('fetch & merge serverside branch')}"
      "git pull -q  slnn serverside || #{echo('no changes on serverside')}",
      "#{echo('merge clientside branch')}"
      "git merge -q clientside -m 'merge clientside'",
      "#{echo('delete clientside branch')}"
      "git branch -q -d clientside"
      "#{echo('push master')}"
      "git push slnn master"



