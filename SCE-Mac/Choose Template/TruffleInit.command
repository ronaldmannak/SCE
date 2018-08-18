#!/bin/sh

cd ${1}
mkdir ${2}
cd ${2}
truffle unbox ${3}
echo 'done.'
