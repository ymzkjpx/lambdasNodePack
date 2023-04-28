#!/bin/bash

set -eu

function Main(){
  echo -e "making zip file...\r"
  tozip &
  show_progress $!
  wait "$!"
  echo -e "\033[31mlambdasNodePack.zip\033[0m"
  exit 0
}

function tozip(){
  sleep 1
  cd lambdasNodePack/
  echo -e "npm install..."
  npm install > /dev/null 2>&1
  echo -e "zipping..."
  cd ../
  zip -qr lambdasNodePack.zip lambdasNodePack/ &
}


function show_progress(){
  local pid=$1
  local delay=0.01
  local spinstr='|/-\'
  local i=0

  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf "\r[%c] " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
  done

  wait "$pid"
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    printf "\r%s\n" "Done."
  else
    printf "\r%s\n" "Failed."
  fi
}

Main
