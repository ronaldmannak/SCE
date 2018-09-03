#!/bin/sh

echo '$ cd '${1}'/'${2}
cd ${1}
mkdir ${2}
cd ${2}

echo ${1}/${2}' $ truffle unbox '${3}
truffle unbox ${3}

echo ${1}/${2}' $ npm install openzeppelin-solidity'
npm install openzeppelin-solidity

echo ${1}/${2}' $ solium --init'
solium --init
echo 'Done.'
