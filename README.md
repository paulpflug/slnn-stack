# slnn-stack

systemd, letsencrypt, node and nginx stack.

Combined with two-way push-to-deploy, with local merging and live pushing.

Useful default settings for fast deploying.

### Install

```sh
# certbot https://certbot.eff.org/
# server only
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot 

# nginx
# server only
sudo apt-get install nginx 

# node 
# server and dev machine
sudo apt-get install npm
npm install npm -g
npm install -g n
n install latest

# slnn-stack
# server and dev machine
npm install -g slnn-stack
```

### Usage

```sh
Usage: slnn [options]

  Options:

    -h, --help        output usage information
    -V, --version     output the version number
    init [folder]     init slnn stack
    setup [type]      setups slnn stack. Type can be omitted or be one of git, nginx, systemd or letsencrypt
    -f, --force       only with setup, overwrites existing configs
    deploy [gitpath]  deploys local copy
    pull              get remote changes


### examples:
# server
slnn init /some/folder
# or
cd /some/folder && slnn init
# will output url to remote repo

# dev machine in project folder
slnn deploy ssh://url-to/remote/repo
# (will automatically call slnn setup on server side)

# you can manually call slnn setup inside remote folder
cd /some/folder && slnn setup

# to rewrite e.g. nginx config after you did some changes:
cd /some/folder && slnn setup nginx --force

# dev machine in project folder for future deploys
slnn deploy
```

### Options
slnn expects a file `slnn.js` in project folder
```coffee
module.exports = {
  name: "project name",
  main: "server/index.js", # entry file on server side

  # relative folder on client side
  # must contain git repo and slnn.js file
  deploy: "deploy", 
  domains:[
    # domains used for letsencrypt and nginx
    # first domain will be main domain, all other will redirect
    "someDomain"
  ],
  # nginx config.
  # use object to overwrite default
  nginx: {
    listen: 8080,
    "location /some":{
      options: "of some location"
    }
  },
  letsencrypt: {},
  # systemd config:
  # use object to overwrite default
  systemd: {
    Unit:{
      Wants: "some-other-service"
    }
  },
  socket: {}, # to enable systemd socket
  port: 9010, # port used server side when not using socket
  hooks: {
    # server side bash script
    beforeStop: ["echo 'service will be stopped shortly'"]
    beforeStart: [""]
    afterStart: [""]
  }
}
```

### Using systemd socket in Node

```js
var port = process.env.LISTEN_FDS ? {fd:3} : 8080
server.listen(port)
```

## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
