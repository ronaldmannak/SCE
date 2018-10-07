#!/bin/sh

# ${1} is work directory
# ${2} is project name
# ${3} is truffle command argument, e.g. "init" or "unbox"
# ${4} (optional) template name

echo '$ cd '${1}
cd ${1}

#HOME=${2}
#export HOME


  # unbox template
echo '$ truffle '${3}' '${4}
truffle ${3} ${4}

  echo '$ npm install openzeppelin-solidity'
  npm install openzeppelin-solidity

  echo '$ solium --init'
  solium --init
#fi

echo 'Done.'
