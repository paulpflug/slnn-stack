# slnn-stack

systemd, letsencrypt, node and nginx stack.

Combined with two-way push-to-deploy, with local merging and live pushing

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
# server
slnn init /some/folder
# or
cd /some/folder && slnn init
# will output url to remote repo

# dev machine in project folder
slnn deploy ssh://url-to/remote/repo
# (will call slnn setup on server side)

# you can manually call slnn setup
slnn setup /some/folder
# or
cd /some/folder && slnn setup

# dev machine in project folder for future deploys
slnn deploy
```

### Options
slnn expects a file `slnn.js` in project folder
```coffee
module.exports ={
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
  nginx: {},
  letsencrypt: {},
  # systemd config:
  systemd: {
    Unit:{
      Wants: "some-other-service"
    }
  },
  socket: {}, # to enable systemd socket
  port: 9010 # port used server side
}
```

### Using systemd socket

```js
var port = process.env.LISTEN_FDS ? {fd:3} : 8080
server.listen(port)
```

## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
