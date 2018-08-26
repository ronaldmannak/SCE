#!/bin/sh

cd ${1}
truffle compile
truffle migrate
#npm run dev
echo 'Done.'
