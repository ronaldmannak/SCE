#!/bin/sh

echo '$ cd '${1}'/'${2}
cd ${1}
#mkdir ${2}
cd ${2}

echo '$ etherlime init'
etherlime init

if [ "$#" -eq  "3" ]
then
  echo '$ npm install openzeppelin-solidity'
  npm install openzeppelin-solidity
fi


#echo '$ solium --init'
#solium --init
echo 'Done.'
