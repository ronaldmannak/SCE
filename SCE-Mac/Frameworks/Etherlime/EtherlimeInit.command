#!/bin/sh

echo '$ cd '${1}
cd ${1}

echo '$ etherlime init'
etherlime init

if [ "$#" -eq  "3" ]
then
  echo '$ npm install openzeppelin-solidity'
  npm install openzeppelin-solidity
fi

echo 'Done.'
