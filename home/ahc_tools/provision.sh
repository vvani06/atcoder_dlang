#!/usr/bin/bash
set -e

cd `dirname $0`
TARGET=$1

declare -A TOOLS_URLS=(
  ["AHC019"]="https://img.atcoder.jp/ahc019/b36525d8.zip"
  ["AHC025"]="https://img.atcoder.jp/ahc025/tNvZmDfV.zip"
  ["AHC026"]="https://img.atcoder.jp/ahc026/lPQezTZx.zip"
  ["AHC027"]="https://img.atcoder.jp/ahc027/aPdjCUIZ_v2.zip"
  ["AHC028"]="https://img.atcoder.jp/ahc028/fWRno7xB.zip"
  ["AHC029"]="https://img.atcoder.jp/ahc029/45e6da0b06.zip"
  ["AHC030"]="https://img.atcoder.jp/ahc030/awGA15Om_v3.zip"
  ["AHC031"]="https://img.atcoder.jp/ahc031/PJcas1sL.zip"
  ["AHC032"]="https://img.atcoder.jp/ahc032/e2weanqa.zip"
  ["AHC033"]="https://img.atcoder.jp/ahc033/ELSlXTEw.zip"
  ["AHC034"]="https://img.atcoder.jp/ahc034/vImT4eac.zip"
)

rm -rf tools tools.zip
curl "${TOOLS_URLS[${TARGET}]}" > tools.zip
unzip tools.zip
cd tools

cargo build -r --bin vis
cp target/release/vis /usr/bin/vis

seq 0 1999 > seeds
cargo run -r --bin gen seeds
rm -rf /ahc_in
cp -r in /ahc_in/

ls ./src/bin
if [ -f ./src/bin/tester* ]; then
  cargo build -r --bin tester
  cp target/release/tester /usr/bin/tester
fi

cd ..
rm -rf tools tools.zip

echo "You can use 'vis' as ${TARGET} visualizer, and input files at /ahc_in/"