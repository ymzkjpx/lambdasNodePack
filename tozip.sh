#!/bin/bash

set -eu

function Main(){
  echo -e "makeing zip file...\r"
  tozip &
  show_progress $!
  wait "$!"
  echo -e "\033[31mlambdasNodePack.zip\033[0m"
  exit 1
}

function tozip(){
  sleep 1
  zip -qr lambdasNodePack.zip node_modules/ &
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
