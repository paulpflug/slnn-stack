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

  else if (type = program.setup) and (folder = get.cwd(program.cwd))
    cfg = getCfg folder
    cfg.silent ?= program.silent
    cfg.force = program.force
    {log,echo, nl} = require("./log")(cfg.silent)
    nl 2
    log "SETUP"
    log "setting up stack"
    cfg.folder = folder
    if type == true or type == "git"
      log "setup git post-receive script"
      postReceive = get.postReceive(folder)
      if not cfg.force and fs.existsSync(postReceive)
        log "git", "found script in #{postReceive}"
        log "git", "cancel setup"
      else
        genCfg.byTemplate 
          filename: postReceive
          cfgname: "git"
          cfg: cfg
        await run "", "chmod +x #{postReceive}"
    for name in ["letsencrypt","nginx","systemd"]
      if cfg[name] and (type == true or type == name)
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
    getCfg deployFolder # only check existence
    await gitInit deployFolder
    if gitpath && gitpath != true
      await run deployFolder, 
        "#{echo('setting up remote url')}"
        "git remote add slnn #{gitpath} || git remote set-url slnn #{gitpath}"
    await run deployFolder, 
      "#{echo('stash changes')}",
      "git stash -q || true",
      "#{echo('checkout clientside branch')}",
      "git checkout -q clientside || git checkout -q -b clientside",
      "#{echo('unstash changes')}",
      "git stash pop -q || true",
      "#{echo('commit all changes')}",
      "git add .",
      "git commit -q -m 'clientside' || true",
      "#{echo('push clientside branch')}",
      "git push -q slnn clientside",
      "#{echo('checkout master branch')}"
      "git checkout -q  master || git checkout -q  -b master"
      "#{echo('fetch & merge serverside branch')}"
      "git pull -q  slnn serverside || #{echo('no changes on serverside')}",
      "#{echo('merge clientside branch')}"
      "git merge -q clientside -m 'merge clientside'",
      "#{echo('push master')}"
      "git push slnn master"
  else if program.pull and (folder = get.cwd(program.cwd))
    cfg = getCfg folder
    cfg.silent ?= program.silent
    {log,echo, nl} = require("./log")(cfg.silent)
    nl 2
    log "PULL"
    deployFolder = path.resolve folder, cfg.deploy
    await run deployFolder, 
      "#{echo('stash changes')}",
      "git stash",
      "#{echo('checkout clientside branch')}",
      "git checkout -q clientside || git checkout -q -b clientside",
      "#{echo('push clientside branch')}",
      "git push -q slnn clientside",
      "#{echo('checkout master branch')}"
      "git checkout -q master || git checkout -q -b master"
      "#{echo('fetch & merge serverside branch')}"
      "git pull -q  slnn serverside || #{echo('no changes on serverside')}",
      "#{echo('push master')}"
      "git push slnn master"
      "#{echo('unstash changes')}",
      "git stash pop",


