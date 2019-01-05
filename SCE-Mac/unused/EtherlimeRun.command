#!/bin/sh

cd ${1}
echo '$ etherlime deploy'
etherlime deploy
echo 'Done.'
