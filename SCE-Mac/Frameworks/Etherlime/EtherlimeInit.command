#!/bin/sh

# ${1} is work directory
# ${2} is project name
# ${3} is truffle command argument, e.g. "init" or "unbox"
# ${4} (optional) template name

echo '$ cd '${1}
cd ${1}

echo '$ etherlime init'
etherlime init

#if [ "$#" -eq  "3" ]
#then
  echo '$ npm install --save-exact openzeppelin-solidity'
  npm install openzeppelin-solidity
#fi

echo 'Done.'
