#!/usr/bin/bash
set -e

apt update -y
apt install -y libfontconfig1-dev pkg-config fontconfig libfontconfig-dev

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
  ["AHC035"]="https://img.atcoder.jp/ahc035/F5dI2O6U.zip"
  ["AHC036"]="https://img.atcoder.jp/ahc036/e5f02df53f30d36e.zip"
  ["AHC037"]="https://img.atcoder.jp/ahc037/WneGTzJP.zip"
  ["AHC038"]="https://img.atcoder.jp/ahc038/GhBuR36w.zip"
  ["AHC039"]="https://img.atcoder.jp/ahc039/KNtTkgAy.zip"
  ["AHC040"]="https://img.atcoder.jp/ahc040/RGoXy7re.zip"
  ["AHC041"]="https://img.atcoder.jp/ahc041/m0Bwp9WL.zip"
  ["AHC042"]="https://img.atcoder.jp/ahc042/cnhLtdRT.zip"
  ["AHC043"]="https://img.atcoder.jp/ahc043/de43f43a9c.zip"
  ["AHC044"]="https://img.atcoder.jp/ahc044/PnJFT8lu.zip"
  ["AHC045"]="https://img.atcoder.jp/ahc045/jOO09LxU_v2.zip"
  ["AHC046"]="https://img.atcoder.jp/ahc046/EuNd3uow.zip"
  ["AHC047"]="https://img.atcoder.jp/ahc047/cHmFekjC.zip"
  ["AHC048"]="https://img.atcoder.jp/ahc048/lI5DXOAV.zip"
  ["AHC049"]="https://img.atcoder.jp/ahc049/LDUZCjLO.zip"
  ["AHC050"]="https://img.atcoder.jp/ahc050/k1BmZE1o.zip"
  ["AHC051"]="https://img.atcoder.jp/ahc051/jdd9gfQC.zip"
  ["AHC052"]="https://img.atcoder.jp/ahc052/ZN1uhrbm.zip"
  ["AHC053"]="https://img.atcoder.jp/ahc053/Q405bDmv.zip"
  ["AHC054"]="https://img.atcoder.jp/ahc054/YDAxDRZr_v2.zip"
  ["AHC055"]="https://img.atcoder.jp/ahc055/ys4u9l6aru.zip"
  ["AHC056"]="https://img.atcoder.jp/ahc056/zUbWUSnS.zip"
  ["AHC057"]="https://img.atcoder.jp/ahc057/BJTm8xSg.zip"
  ["AHC058"]="https://img.atcoder.jp/ahc058/UpvAVdx6.zip"
  ["AHC059"]="https://img.atcoder.jp/ahc059/b8ckwh7N.zip"
)

rm -rf tools tools.zip
curl "${TOOLS_URLS[${TARGET}]}" > tools.zip
unzip tools.zip
cd tools

cargo build -r --bin vis
cp target/release/vis /usr/bin/vis

seq 0 9999 > seeds
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