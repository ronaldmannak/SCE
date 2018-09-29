#!/bin/sh

# ${1} is base directory
# ${2} is project name
# ${3} (optional) is

echo '$ cd '${1}'/'${2}
cd ${1}
mkdir ${2}
cd ${2}

HOME=${2}
export HOME

if [ "$#" -eq  "2" ]
then

# Create an empty project
  echo '$ truffle init'
  truffle init

else

  # unbox template
  echo '$ truffle unbox '${3}
  truffle unbox ${3}

  echo '$ npm install openzeppelin-solidity'
  npm install openzeppelin-solidity

  echo '$ solium --init'
  solium --init
fi

echo 'Done.'
