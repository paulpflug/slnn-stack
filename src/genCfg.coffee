fs = require "fs-extra"
{isObject} = require "./helper"

objTo =
  systemd: (obj) ->
    str = ""
    for k,v of obj
      str += "\n" if str
      str += "[#{k}]\n"
      for k2,v2 of v
        str += "#{k2}=#{v2}\n"
    return str 
  nginx: (obj) ->
    str = "server {\n"
    for k,v of obj
      unless isObject(v)
        str += "  #{k} #{v};\n"
      else
        str += "  #{k} {\n"
        for k2,v2 of v
          str += "    #{k2} #{v2};\n"
        str += "  }\n"
    str += "}\n"
    return str

assign = (obj1, obj2) ->
  if obj2
    for k,v of obj1
      if obj2[k]
        if isObject(v)
          obj1[k] = Object.assign v, obj2[k]
        else
          obj1[k] = obj2[k]
    for k,v of obj2
      obj1[k] = v unless obj1[k]?
  for k,v of obj1
    if isObject(v)
      for k2,v2 of v
        unless v2
          delete v[k2]
    else unless v
      delete obj1[k]
  return obj1

writeFile = ({filename, content, cfgname, cfg}) ->
  if cfgname? and (not cfg or not cfg.silent)
    console.log "slnn: writing config #{cfgname} to #{filename}"
  fs.outputFileSync filename, content

getFile = (cfgname) -> require("./cfg.#{cfgname}")

mergeWithDefault = ({cfg, cfgname, objToMerge, options}) -> 
  defaultsObjGen = getFile(cfgname)
  assign defaultsObjGen(cfg, options), objToMerge

byTemplate = ({cfg, filename, cfgname}) ->
  template = getFile(cfgname)
  writeFile 
    filename: filename 
    content: template(cfg)
    cfgname: cfgname
    cfg: cfg
byDefault = ({cfg, filename, cfgname, objToMerge, type}) -> 
  obj = mergeWithDefault(cfg:cfg, cfgname:cfgname, objToMerge:objToMerge)
  writeFile 
    filename: filename
    content: objTo[type](obj)
    cfgname: cfgname
    cfg: cfg 
module.exports =
  writeFile: writeFile
  mergeWithDefault: mergeWithDefault
  byTemplate: byTemplate
  byDefault: byDefault
  objTo: objTo
  use: (cfg) ->
    writeFile: writeFile
    mergeWithDefault: (obj) -> mergeWithDefault(Object.assign(cfg:cfg, obj))
    byTemplate: (obj) -> byTemplate(Object.assign(cfg:cfg, obj))
    byDefault: (obj) -> byDefault(Object.assign(cfg:cfg, obj))
    objTo: objTo