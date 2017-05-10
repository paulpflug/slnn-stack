chai = require "chai"
should = chai.should()
#{run} = require "../src/helper"
slnn = require "../src/slnn"
genCfg = require "../src/genCfg"
uncache = require "recursive-uncache"
fs = require "fs-extra"
which = require "which"
{resolve} = require "path"
read = (name) -> fs.readFileSync(name,"utf8")
p = resolve.bind null, "./tmp"
p2 = resolve.bind null, "./test"
cfg = """
  module.exports =
    name: "test"
    main: "server.js"
    deploy: "deploy"
    nginx: {}
    systemd:
      Service:
        ExecStart: "someexec"
        WorkingDirectory: "cwd"
    socket: {}
    paths:
      nginx: "#{p("testnginx")}"
      systemd: "#{p("systemd")}"
    silent: true
"""

testFile = p("test")
describe "slnn", ->
  before ->
    fs.removeSync p()
    
  it "should work", ->
    await slnn init: p("remote"), silent: true
    fs.mkdirsSync p("local/deploy")
    fs.writeFileSync p("local/slnn.coffee"),cfg
    fs.writeFileSync p("local/deploy/slnn.coffee"),cfg
    
    slnn deploy: p("remote"), cwd: p("local"), silent: true
    .then ->
      read(p("testnginx")).should.equal read(p2("nginxtest"))
      read(p("systemd.service")).should.equal read(p2("systemdtest"))
      read(p("systemd.socket")).should.equal read(p2("systemdsocket"))
  describe "genCfg", ->
    it "should create init git post receive hook by template", ->
      genCfg.byTemplate filename: testFile, cfgname:"git.init", cfg:silent: true
      read(testFile).should.equal require("../src/cfg.git.init.coffee")()
    it "should create git post receive hook by template", ->
      genCfg.byTemplate 
        filename: testFile
        cfgname:"git"
        cfg:
          name: "test"
          silent: true
          hooks: 
            beforeStart: "echo 'test'"
            beforeStop: ["test1","test2"]
      read(testFile).should.equal read(p2("gittest"))
    it "should create systemd service", ->
      genCfg.byDefault 
        filename: testFile
        cfgname:"systemd.service"
        type: "systemd"
        cfg:
          silent: true
          name: "test"
          main: "main"
          folder: "cwd"
        objToMerge:
          Service:
            ExecStart: "someexec"
      read(testFile).should.equal read(p2("systemdtest"))
    it "should create nginx config", ->
      genCfg.byDefault 
        filename: testFile
        cfgname:"nginx.proxy"
        type: "nginx"
        cfg:
          silent: true
          name: "test"
          socket: true
      read(testFile).should.equal read(p2("nginxtest"))



  after ->
    delete require.cache[p("local/deploy/slnn.coffee")]
    delete require.cache[p("local/slnn.coffee")]