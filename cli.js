#!/usr/bin/env node
var program = require('commander')
  , fs = require('fs')
  , path = require('path')
  , cwd = process.cwd()
program
  .version(JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8')).version)
  .option("init [folder]", "init slnn stack")
  .option("setup [type]", "setups slnn stack. Type can be omitted or be one of git, nginx, systemd or letsencrypt")
  .option("-f, --force", "only with setup, overwrites existing configs")
  .option("deploy [gitpath]", "deploys local copy")
  .option("pull", "get remote changes")
  .parse(process.argv);
require("./lib/slnn.js")(program)["catch"](function (e) {
  console.log(e)
})
