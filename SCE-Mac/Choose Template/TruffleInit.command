#!/bin/sh

cd ${1}
#rm -r @{2}
mkdir ${2}
cd ${2}
truffle unbox ${3}
npm install openzeppelin-solidity
echo 'Done.'
