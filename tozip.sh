#!/bin/bash

set -eu

function Main(){
  tozip
}

function tozip(){
  echo "makeing zip file..."
  zip -qr lambdasNodePack.zip node_modules/ &
  show_progress "$!"
  echo -e "finished. created: \033[31mlambdasNodePack.zip\033[0m"
  exit 1
}

function show_progress() {
  local -r delay='0.1'   # 進行状況の更新間隔（秒）
  local -r char='/-\|'   # ローダーに使用する文字
  local i=0

  while [[ -e /proc/$1 ]]; do
    i=$(( (i+1) %4 ))
    printf "\r[%c] " "${char:$i:1}"
    sleep "${delay}"
  done
  printf "\r[%c] Done!\n" "${char:$i:1}"
}

Main
