#!/usr/bin/env node
var program = require('commander')
  , fs = require('fs')
  , path = require('path')
  , cwd = process.cwd()
program
  .version(JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8')).version)
  .option("init [folder]", "init slnn stack")
  .option("setup [folder]", "setups slnn stack")
  .option("deploy [gitpath]", "deploys local copy")
  .parse(process.argv);
require("./lib/slnn.js")(program)["catch"](function (e) {
  console.log(e)
})
