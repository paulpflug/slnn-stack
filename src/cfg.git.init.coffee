module.exports = (cfg) -> """
#!/bin/bash
{
  cd ..
  unset GIT_DIR
  while read oldrev newrev refname
  do 
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    if [ "clientside" = "$branch" ]; then
      git checkout clientside -q
      slnn setup
    fi
  done
  exit
}
"""
