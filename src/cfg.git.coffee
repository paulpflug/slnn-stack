module.exports = (cfg) -> 
  getHook = (name) ->
    arr = cfg.hooks?[name]
    return "" unless arr?
    arr = [arr] unless Array.isArray(arr)
    return arr.join("\n    ")
  return """
    #!/bin/bash
    cd ..
    unset GIT_DIR
    while read oldrev newrev refname
    do
      branch=$(git rev-parse --symbolic --abbrev-ref $refname)
      if [ "master" = "$branch" ]; then
        echo "slnn: checkout master"
        git checkout -q master || git checkout -q -b master
        echo "slnn: delete serverside branch"
        git branch -q -d serverside
        git reset HEAD --hard
        #{getHook("beforeInstall")}
        echo "slnn: installing node modules"
        npm install --production
        #{getHook("beforeStop")}
        echo "slnn: restarting service #{cfg.name}"
        service #{cfg.name} stop
        #{getHook("beforeStart")}
        service #{cfg.name} start
        #{getHook("afterStart")}
      elif [ "clientside" = "$branch" ]; then
        echo "slnn: checkout serverside branch"
        git checkout -q -b serverside
        echo "slnn: commit serverside changes"
        git add .
        git commit -q -m "serverside changes"
      fi
    done
    """
