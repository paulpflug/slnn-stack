module.exports = (cfg) -> """
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
    echo "slnn: installing node modules"
    npm install --production
    echo "slnn: restarting service #{cfg.name}"
    service #{cfg.name} restart
  elif [ "clientside" = "$branch" ]; then
    git branch -q -d clientside
    echo "slnn: checkout serverside branch"
    git checkout -q -b serverside
    echo "slnn: commit serverside changes"
    git add . 
    git commit -q -m "serverside changes"
  fi
done
"""
