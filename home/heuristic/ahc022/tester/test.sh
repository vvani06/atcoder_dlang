#!/bin/bash -e

ldmd2 -O -release ../src/a.d -of ./a
touch score
rm score
rm out/*

./tester ./a < in/0000.txt > out/0000.txt 2> out/0000_score &
./tester ./a < in/0001.txt > out/0001.txt 2> out/0001_score &
./tester ./a < in/0002.txt > out/0002.txt 2> out/0002_score &
./tester ./a < in/0003.txt > out/0003.txt 2> out/0003_score &
./tester ./a < in/0004.txt > out/0004.txt 2> out/0004_score &
./tester ./a < in/0005.txt > out/0005.txt 2> out/0005_score &
./tester ./a < in/0006.txt > out/0006.txt 2> out/0006_score &
./tester ./a < in/0007.txt > out/0007.txt 2> out/0007_score &
./tester ./a < in/0008.txt > out/0008.txt 2> out/0008_score &
./tester ./a < in/0009.txt > out/0009.txt 2> out/0009_score &
./tester ./a < in/0010.txt > out/0010.txt 2> out/0010_score &
./tester ./a < in/0011.txt > out/0011.txt 2> out/0011_score &
./tester ./a < in/0012.txt > out/0012.txt 2> out/0012_score &
./tester ./a < in/0013.txt > out/0013.txt 2> out/0013_score &
./tester ./a < in/0014.txt > out/0014.txt 2> out/0014_score &
./tester ./a < in/0015.txt > out/0015.txt 2> out/0015_score &
./tester ./a < in/0016.txt > out/0016.txt 2> out/0016_score &
./tester ./a < in/0017.txt > out/0017.txt 2> out/0017_score &
./tester ./a < in/0018.txt > out/0018.txt 2> out/0018_score &
./tester ./a < in/0019.txt > out/0019.txt 2> out/0019_score &
./tester ./a < in/0020.txt > out/0020.txt 2> out/0020_score &
./tester ./a < in/0021.txt > out/0021.txt 2> out/0021_score &
./tester ./a < in/0022.txt > out/0022.txt 2> out/0022_score &
./tester ./a < in/0023.txt > out/0023.txt 2> out/0023_score &
./tester ./a < in/0024.txt > out/0024.txt 2> out/0024_score &
./tester ./a < in/0025.txt > out/0025.txt 2> out/0025_score &
./tester ./a < in/0026.txt > out/0026.txt 2> out/0026_score &
./tester ./a < in/0027.txt > out/0027.txt 2> out/0027_score &
./tester ./a < in/0028.txt > out/0028.txt 2> out/0028_score &
./tester ./a < in/0029.txt > out/0029.txt 2> out/0029_score &
./tester ./a < in/0030.txt > out/0030.txt 2> out/0030_score &
./tester ./a < in/0031.txt > out/0031.txt 2> out/0031_score &
./tester ./a < in/0032.txt > out/0032.txt 2> out/0032_score &
./tester ./a < in/0033.txt > out/0033.txt 2> out/0033_score &
./tester ./a < in/0034.txt > out/0034.txt 2> out/0034_score &
./tester ./a < in/0035.txt > out/0035.txt 2> out/0035_score &
./tester ./a < in/0036.txt > out/0036.txt 2> out/0036_score &
./tester ./a < in/0037.txt > out/0037.txt 2> out/0037_score &
./tester ./a < in/0038.txt > out/0038.txt 2> out/0038_score &
./tester ./a < in/0039.txt > out/0039.txt 2> out/0039_score &
./tester ./a < in/0040.txt > out/0040.txt 2> out/0040_score &
./tester ./a < in/0041.txt > out/0041.txt 2> out/0041_score &
./tester ./a < in/0042.txt > out/0042.txt 2> out/0042_score &
./tester ./a < in/0043.txt > out/0043.txt 2> out/0043_score &
./tester ./a < in/0044.txt > out/0044.txt 2> out/0044_score &
./tester ./a < in/0045.txt > out/0045.txt 2> out/0045_score &
./tester ./a < in/0046.txt > out/0046.txt 2> out/0046_score &
./tester ./a < in/0047.txt > out/0047.txt 2> out/0047_score &
./tester ./a < in/0048.txt > out/0048.txt 2> out/0048_score &
./tester ./a < in/0049.txt > out/0049.txt 2> out/0049_score &
./tester ./a < in/0050.txt > out/0050.txt 2> out/0050_score &
./tester ./a < in/0051.txt > out/0051.txt 2> out/0051_score &
./tester ./a < in/0052.txt > out/0052.txt 2> out/0052_score &
./tester ./a < in/0053.txt > out/0053.txt 2> out/0053_score &
./tester ./a < in/0054.txt > out/0054.txt 2> out/0054_score &
./tester ./a < in/0055.txt > out/0055.txt 2> out/0055_score &
./tester ./a < in/0056.txt > out/0056.txt 2> out/0056_score &
./tester ./a < in/0057.txt > out/0057.txt 2> out/0057_score &
./tester ./a < in/0058.txt > out/0058.txt 2> out/0058_score &
./tester ./a < in/0059.txt > out/0059.txt 2> out/0059_score &
./tester ./a < in/0060.txt > out/0060.txt 2> out/0060_score &
./tester ./a < in/0061.txt > out/0061.txt 2> out/0061_score &
./tester ./a < in/0062.txt > out/0062.txt 2> out/0062_score &
./tester ./a < in/0063.txt > out/0063.txt 2> out/0063_score &
./tester ./a < in/0064.txt > out/0064.txt 2> out/0064_score &
./tester ./a < in/0065.txt > out/0065.txt 2> out/0065_score &
./tester ./a < in/0066.txt > out/0066.txt 2> out/0066_score &
./tester ./a < in/0067.txt > out/0067.txt 2> out/0067_score &
./tester ./a < in/0068.txt > out/0068.txt 2> out/0068_score &
./tester ./a < in/0069.txt > out/0069.txt 2> out/0069_score &
./tester ./a < in/0070.txt > out/0070.txt 2> out/0070_score &
./tester ./a < in/0071.txt > out/0071.txt 2> out/0071_score &
./tester ./a < in/0072.txt > out/0072.txt 2> out/0072_score &
./tester ./a < in/0073.txt > out/0073.txt 2> out/0073_score &
./tester ./a < in/0074.txt > out/0074.txt 2> out/0074_score &
./tester ./a < in/0075.txt > out/0075.txt 2> out/0075_score &
./tester ./a < in/0076.txt > out/0076.txt 2> out/0076_score &
./tester ./a < in/0077.txt > out/0077.txt 2> out/0077_score &
./tester ./a < in/0078.txt > out/0078.txt 2> out/0078_score &
./tester ./a < in/0079.txt > out/0079.txt 2> out/0079_score &
./tester ./a < in/0080.txt > out/0080.txt 2> out/0080_score &
./tester ./a < in/0081.txt > out/0081.txt 2> out/0081_score &
./tester ./a < in/0082.txt > out/0082.txt 2> out/0082_score &
./tester ./a < in/0083.txt > out/0083.txt 2> out/0083_score &
./tester ./a < in/0084.txt > out/0084.txt 2> out/0084_score &
./tester ./a < in/0085.txt > out/0085.txt 2> out/0085_score &
./tester ./a < in/0086.txt > out/0086.txt 2> out/0086_score &
./tester ./a < in/0087.txt > out/0087.txt 2> out/0087_score &
./tester ./a < in/0088.txt > out/0088.txt 2> out/0088_score &
./tester ./a < in/0089.txt > out/0089.txt 2> out/0089_score &
./tester ./a < in/0090.txt > out/0090.txt 2> out/0090_score &
./tester ./a < in/0091.txt > out/0091.txt 2> out/0091_score &
./tester ./a < in/0092.txt > out/0092.txt 2> out/0092_score &
./tester ./a < in/0093.txt > out/0093.txt 2> out/0093_score &
./tester ./a < in/0094.txt > out/0094.txt 2> out/0094_score &
./tester ./a < in/0095.txt > out/0095.txt 2> out/0095_score &
./tester ./a < in/0096.txt > out/0096.txt 2> out/0096_score &
./tester ./a < in/0097.txt > out/0097.txt 2> out/0097_score &
./tester ./a < in/0098.txt > out/0098.txt 2> out/0098_score &
./tester ./a < in/0099.txt > out/0099.txt 2> out/0099_score &

wait

cat out/0000_score >> score
cat out/0001_score >> score
cat out/0002_score >> score
cat out/0003_score >> score
cat out/0004_score >> score
cat out/0005_score >> score
cat out/0006_score >> score
cat out/0007_score >> score
cat out/0008_score >> score
cat out/0009_score >> score
cat out/0010_score >> score
cat out/0011_score >> score
cat out/0012_score >> score
cat out/0013_score >> score
cat out/0014_score >> score
cat out/0015_score >> score
cat out/0016_score >> score
cat out/0017_score >> score
cat out/0018_score >> score
cat out/0019_score >> score
cat out/0020_score >> score
cat out/0021_score >> score
cat out/0022_score >> score
cat out/0023_score >> score
cat out/0024_score >> score
cat out/0025_score >> score
cat out/0026_score >> score
cat out/0027_score >> score
cat out/0028_score >> score
cat out/0029_score >> score
cat out/0030_score >> score
cat out/0031_score >> score
cat out/0032_score >> score
cat out/0033_score >> score
cat out/0034_score >> score
cat out/0035_score >> score
cat out/0036_score >> score
cat out/0037_score >> score
cat out/0038_score >> score
cat out/0039_score >> score
cat out/0040_score >> score
cat out/0041_score >> score
cat out/0042_score >> score
cat out/0043_score >> score
cat out/0044_score >> score
cat out/0045_score >> score
cat out/0046_score >> score
cat out/0047_score >> score
cat out/0048_score >> score
cat out/0049_score >> score
cat out/0050_score >> score
cat out/0051_score >> score
cat out/0052_score >> score
cat out/0053_score >> score
cat out/0054_score >> score
cat out/0055_score >> score
cat out/0056_score >> score
cat out/0057_score >> score
cat out/0058_score >> score
cat out/0059_score >> score
cat out/0060_score >> score
cat out/0061_score >> score
cat out/0062_score >> score
cat out/0063_score >> score
cat out/0064_score >> score
cat out/0065_score >> score
cat out/0066_score >> score
cat out/0067_score >> score
cat out/0068_score >> score
cat out/0069_score >> score
cat out/0070_score >> score
cat out/0071_score >> score
cat out/0072_score >> score
cat out/0073_score >> score
cat out/0074_score >> score
cat out/0075_score >> score
cat out/0076_score >> score
cat out/0077_score >> score
cat out/0078_score >> score
cat out/0079_score >> score
cat out/0080_score >> score
cat out/0081_score >> score
cat out/0082_score >> score
cat out/0083_score >> score
cat out/0084_score >> score
cat out/0085_score >> score
cat out/0086_score >> score
cat out/0087_score >> score
cat out/0088_score >> score
cat out/0089_score >> score
cat out/0090_score >> score
cat out/0091_score >> score
cat out/0092_score >> score
cat out/0093_score >> score
cat out/0094_score >> score
cat out/0095_score >> score
cat out/0096_score >> score
cat out/0097_score >> score
cat out/0098_score >> score
cat out/0099_score >> score

SCORE=`cat score | grep Score | awk '{sum+=$3} END {printf "%.2f\n", sum / 100}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
