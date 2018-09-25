#!/bin/sh

echo '$ cd '${1}'/'${2}
cd ${1}
mkdir ${2}
cd ${2}

echo '$ etherlime init'
etherlime init

#echo '$ npm install openzeppelin-solidity'
#npm install openzeppelin-solidity

#echo '$ solium --init'
#solium --init
echo 'Done.'
