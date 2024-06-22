#!/bin/bash -e

cd `dirname $0`

ldmd2 -O -release ../src/a.d -of ./a
touch score
rm score
rm out/*

echo 0000 > out/0000_score; head -n 1 in/0000.txt >> out/0000_score; 
echo 0001 > out/0001_score; head -n 1 in/0001.txt >> out/0001_score; 
echo 0002 > out/0002_score; head -n 1 in/0002.txt >> out/0002_score; 
echo 0003 > out/0003_score; head -n 1 in/0003.txt >> out/0003_score; 
echo 0004 > out/0004_score; head -n 1 in/0004.txt >> out/0004_score; 
echo 0005 > out/0005_score; head -n 1 in/0005.txt >> out/0005_score; 
echo 0006 > out/0006_score; head -n 1 in/0006.txt >> out/0006_score; 
echo 0007 > out/0007_score; head -n 1 in/0007.txt >> out/0007_score; 
echo 0008 > out/0008_score; head -n 1 in/0008.txt >> out/0008_score; 
echo 0009 > out/0009_score; head -n 1 in/0009.txt >> out/0009_score; 
echo 0010 > out/0010_score; head -n 1 in/0010.txt >> out/0010_score; 
echo 0011 > out/0011_score; head -n 1 in/0011.txt >> out/0011_score; 
echo 0012 > out/0012_score; head -n 1 in/0012.txt >> out/0012_score; 
echo 0013 > out/0013_score; head -n 1 in/0013.txt >> out/0013_score; 
echo 0014 > out/0014_score; head -n 1 in/0014.txt >> out/0014_score; 
echo 0015 > out/0015_score; head -n 1 in/0015.txt >> out/0015_score; 
echo 0016 > out/0016_score; head -n 1 in/0016.txt >> out/0016_score; 
echo 0017 > out/0017_score; head -n 1 in/0017.txt >> out/0017_score; 
echo 0018 > out/0018_score; head -n 1 in/0018.txt >> out/0018_score; 
echo 0019 > out/0019_score; head -n 1 in/0019.txt >> out/0019_score; 
echo 0020 > out/0020_score; head -n 1 in/0020.txt >> out/0020_score; 
echo 0021 > out/0021_score; head -n 1 in/0021.txt >> out/0021_score; 
echo 0022 > out/0022_score; head -n 1 in/0022.txt >> out/0022_score; 
echo 0023 > out/0023_score; head -n 1 in/0023.txt >> out/0023_score; 
echo 0024 > out/0024_score; head -n 1 in/0024.txt >> out/0024_score; 
echo 0025 > out/0025_score; head -n 1 in/0025.txt >> out/0025_score; 
echo 0026 > out/0026_score; head -n 1 in/0026.txt >> out/0026_score; 
echo 0027 > out/0027_score; head -n 1 in/0027.txt >> out/0027_score; 
echo 0028 > out/0028_score; head -n 1 in/0028.txt >> out/0028_score; 
echo 0029 > out/0029_score; head -n 1 in/0029.txt >> out/0029_score; 
echo 0030 > out/0030_score; head -n 1 in/0030.txt >> out/0030_score; 
echo 0031 > out/0031_score; head -n 1 in/0031.txt >> out/0031_score; 
echo 0032 > out/0032_score; head -n 1 in/0032.txt >> out/0032_score; 
echo 0033 > out/0033_score; head -n 1 in/0033.txt >> out/0033_score; 
echo 0034 > out/0034_score; head -n 1 in/0034.txt >> out/0034_score; 
echo 0035 > out/0035_score; head -n 1 in/0035.txt >> out/0035_score; 
echo 0036 > out/0036_score; head -n 1 in/0036.txt >> out/0036_score; 
echo 0037 > out/0037_score; head -n 1 in/0037.txt >> out/0037_score; 
echo 0038 > out/0038_score; head -n 1 in/0038.txt >> out/0038_score; 
echo 0039 > out/0039_score; head -n 1 in/0039.txt >> out/0039_score; 
echo 0040 > out/0040_score; head -n 1 in/0040.txt >> out/0040_score; 
echo 0041 > out/0041_score; head -n 1 in/0041.txt >> out/0041_score; 
echo 0042 > out/0042_score; head -n 1 in/0042.txt >> out/0042_score; 
echo 0043 > out/0043_score; head -n 1 in/0043.txt >> out/0043_score; 
echo 0044 > out/0044_score; head -n 1 in/0044.txt >> out/0044_score; 
echo 0045 > out/0045_score; head -n 1 in/0045.txt >> out/0045_score; 
echo 0046 > out/0046_score; head -n 1 in/0046.txt >> out/0046_score; 
echo 0047 > out/0047_score; head -n 1 in/0047.txt >> out/0047_score; 
echo 0048 > out/0048_score; head -n 1 in/0048.txt >> out/0048_score; 
echo 0049 > out/0049_score; head -n 1 in/0049.txt >> out/0049_score; 
echo 0050 > out/0050_score; head -n 1 in/0050.txt >> out/0050_score; 
echo 0051 > out/0051_score; head -n 1 in/0051.txt >> out/0051_score; 
echo 0052 > out/0052_score; head -n 1 in/0052.txt >> out/0052_score; 
echo 0053 > out/0053_score; head -n 1 in/0053.txt >> out/0053_score; 
echo 0054 > out/0054_score; head -n 1 in/0054.txt >> out/0054_score; 
echo 0055 > out/0055_score; head -n 1 in/0055.txt >> out/0055_score; 
echo 0056 > out/0056_score; head -n 1 in/0056.txt >> out/0056_score; 
echo 0057 > out/0057_score; head -n 1 in/0057.txt >> out/0057_score; 
echo 0058 > out/0058_score; head -n 1 in/0058.txt >> out/0058_score; 
echo 0059 > out/0059_score; head -n 1 in/0059.txt >> out/0059_score; 
echo 0060 > out/0060_score; head -n 1 in/0060.txt >> out/0060_score; 
echo 0061 > out/0061_score; head -n 1 in/0061.txt >> out/0061_score; 
echo 0062 > out/0062_score; head -n 1 in/0062.txt >> out/0062_score; 
echo 0063 > out/0063_score; head -n 1 in/0063.txt >> out/0063_score; 
echo 0064 > out/0064_score; head -n 1 in/0064.txt >> out/0064_score; 
echo 0065 > out/0065_score; head -n 1 in/0065.txt >> out/0065_score; 
echo 0066 > out/0066_score; head -n 1 in/0066.txt >> out/0066_score; 
echo 0067 > out/0067_score; head -n 1 in/0067.txt >> out/0067_score; 
echo 0068 > out/0068_score; head -n 1 in/0068.txt >> out/0068_score; 
echo 0069 > out/0069_score; head -n 1 in/0069.txt >> out/0069_score; 
echo 0070 > out/0070_score; head -n 1 in/0070.txt >> out/0070_score; 
echo 0071 > out/0071_score; head -n 1 in/0071.txt >> out/0071_score; 
echo 0072 > out/0072_score; head -n 1 in/0072.txt >> out/0072_score; 
echo 0073 > out/0073_score; head -n 1 in/0073.txt >> out/0073_score; 
echo 0074 > out/0074_score; head -n 1 in/0074.txt >> out/0074_score; 
echo 0075 > out/0075_score; head -n 1 in/0075.txt >> out/0075_score; 
echo 0076 > out/0076_score; head -n 1 in/0076.txt >> out/0076_score; 
echo 0077 > out/0077_score; head -n 1 in/0077.txt >> out/0077_score; 
echo 0078 > out/0078_score; head -n 1 in/0078.txt >> out/0078_score; 
echo 0079 > out/0079_score; head -n 1 in/0079.txt >> out/0079_score; 
echo 0080 > out/0080_score; head -n 1 in/0080.txt >> out/0080_score; 
echo 0081 > out/0081_score; head -n 1 in/0081.txt >> out/0081_score; 
echo 0082 > out/0082_score; head -n 1 in/0082.txt >> out/0082_score; 
echo 0083 > out/0083_score; head -n 1 in/0083.txt >> out/0083_score; 
echo 0084 > out/0084_score; head -n 1 in/0084.txt >> out/0084_score; 
echo 0085 > out/0085_score; head -n 1 in/0085.txt >> out/0085_score; 
echo 0086 > out/0086_score; head -n 1 in/0086.txt >> out/0086_score; 
echo 0087 > out/0087_score; head -n 1 in/0087.txt >> out/0087_score; 
echo 0088 > out/0088_score; head -n 1 in/0088.txt >> out/0088_score; 
echo 0089 > out/0089_score; head -n 1 in/0089.txt >> out/0089_score; 
echo 0090 > out/0090_score; head -n 1 in/0090.txt >> out/0090_score; 
echo 0091 > out/0091_score; head -n 1 in/0091.txt >> out/0091_score; 
echo 0092 > out/0092_score; head -n 1 in/0092.txt >> out/0092_score; 
echo 0093 > out/0093_score; head -n 1 in/0093.txt >> out/0093_score; 
echo 0094 > out/0094_score; head -n 1 in/0094.txt >> out/0094_score; 
echo 0095 > out/0095_score; head -n 1 in/0095.txt >> out/0095_score; 
echo 0096 > out/0096_score; head -n 1 in/0096.txt >> out/0096_score; 
echo 0097 > out/0097_score; head -n 1 in/0097.txt >> out/0097_score; 
echo 0098 > out/0098_score; head -n 1 in/0098.txt >> out/0098_score; 
echo 0099 > out/0099_score; head -n 1 in/0099.txt >> out/0099_score; 

./a < in/0000.txt > out/0000.txt &
./a < in/0001.txt > out/0001.txt &
./a < in/0002.txt > out/0002.txt &
./a < in/0003.txt > out/0003.txt &
./a < in/0004.txt > out/0004.txt &
./a < in/0005.txt > out/0005.txt &
./a < in/0006.txt > out/0006.txt &
./a < in/0007.txt > out/0007.txt &
./a < in/0008.txt > out/0008.txt &
./a < in/0009.txt > out/0009.txt &
./a < in/0010.txt > out/0010.txt &
./a < in/0011.txt > out/0011.txt &
./a < in/0012.txt > out/0012.txt &
./a < in/0013.txt > out/0013.txt &
./a < in/0014.txt > out/0014.txt &
./a < in/0015.txt > out/0015.txt &
./a < in/0016.txt > out/0016.txt &
./a < in/0017.txt > out/0017.txt &
./a < in/0018.txt > out/0018.txt &
./a < in/0019.txt > out/0019.txt &
./a < in/0020.txt > out/0020.txt &
./a < in/0021.txt > out/0021.txt &
./a < in/0022.txt > out/0022.txt &
./a < in/0023.txt > out/0023.txt &
./a < in/0024.txt > out/0024.txt &
./a < in/0025.txt > out/0025.txt &
./a < in/0026.txt > out/0026.txt &
./a < in/0027.txt > out/0027.txt &
./a < in/0028.txt > out/0028.txt &
./a < in/0029.txt > out/0029.txt &
./a < in/0030.txt > out/0030.txt &
./a < in/0031.txt > out/0031.txt &
./a < in/0032.txt > out/0032.txt &
./a < in/0033.txt > out/0033.txt &
./a < in/0034.txt > out/0034.txt &
./a < in/0035.txt > out/0035.txt &
./a < in/0036.txt > out/0036.txt &
./a < in/0037.txt > out/0037.txt &
./a < in/0038.txt > out/0038.txt &
./a < in/0039.txt > out/0039.txt &
./a < in/0040.txt > out/0040.txt &
./a < in/0041.txt > out/0041.txt &
./a < in/0042.txt > out/0042.txt &
./a < in/0043.txt > out/0043.txt &
./a < in/0044.txt > out/0044.txt &
./a < in/0045.txt > out/0045.txt &
./a < in/0046.txt > out/0046.txt &
./a < in/0047.txt > out/0047.txt &
./a < in/0048.txt > out/0048.txt &
./a < in/0049.txt > out/0049.txt &
./a < in/0050.txt > out/0050.txt &
./a < in/0051.txt > out/0051.txt &
./a < in/0052.txt > out/0052.txt &
./a < in/0053.txt > out/0053.txt &
./a < in/0054.txt > out/0054.txt &
./a < in/0055.txt > out/0055.txt &
./a < in/0056.txt > out/0056.txt &
./a < in/0057.txt > out/0057.txt &
./a < in/0058.txt > out/0058.txt &
./a < in/0059.txt > out/0059.txt &
./a < in/0060.txt > out/0060.txt &
./a < in/0061.txt > out/0061.txt &
./a < in/0062.txt > out/0062.txt &
./a < in/0063.txt > out/0063.txt &
./a < in/0064.txt > out/0064.txt &
./a < in/0065.txt > out/0065.txt &
./a < in/0066.txt > out/0066.txt &
./a < in/0067.txt > out/0067.txt &
./a < in/0068.txt > out/0068.txt &
./a < in/0069.txt > out/0069.txt &
./a < in/0070.txt > out/0070.txt &
./a < in/0071.txt > out/0071.txt &
./a < in/0072.txt > out/0072.txt &
./a < in/0073.txt > out/0073.txt &
./a < in/0074.txt > out/0074.txt &
./a < in/0075.txt > out/0075.txt &
./a < in/0076.txt > out/0076.txt &
./a < in/0077.txt > out/0077.txt &
./a < in/0078.txt > out/0078.txt &
./a < in/0079.txt > out/0079.txt &
./a < in/0080.txt > out/0080.txt &
./a < in/0081.txt > out/0081.txt &
./a < in/0082.txt > out/0082.txt &
./a < in/0083.txt > out/0083.txt &
./a < in/0084.txt > out/0084.txt &
./a < in/0085.txt > out/0085.txt &
./a < in/0086.txt > out/0086.txt &
./a < in/0087.txt > out/0087.txt &
./a < in/0088.txt > out/0088.txt &
./a < in/0089.txt > out/0089.txt &
./a < in/0090.txt > out/0090.txt &
./a < in/0091.txt > out/0091.txt &
./a < in/0092.txt > out/0092.txt &
./a < in/0093.txt > out/0093.txt &
./a < in/0094.txt > out/0094.txt &
./a < in/0095.txt > out/0095.txt &
./a < in/0096.txt > out/0096.txt &
./a < in/0097.txt > out/0097.txt &
./a < in/0098.txt > out/0098.txt &
./a < in/0099.txt > out/0099.txt &

wait

./vis in/0000.txt out/0000.txt >> out/0000_score &
./vis in/0001.txt out/0001.txt >> out/0001_score &
./vis in/0002.txt out/0002.txt >> out/0002_score &
./vis in/0003.txt out/0003.txt >> out/0003_score &
./vis in/0004.txt out/0004.txt >> out/0004_score &
./vis in/0005.txt out/0005.txt >> out/0005_score &
./vis in/0006.txt out/0006.txt >> out/0006_score &
./vis in/0007.txt out/0007.txt >> out/0007_score &
./vis in/0008.txt out/0008.txt >> out/0008_score &
./vis in/0009.txt out/0009.txt >> out/0009_score &
./vis in/0010.txt out/0010.txt >> out/0010_score &
./vis in/0011.txt out/0011.txt >> out/0011_score &
./vis in/0012.txt out/0012.txt >> out/0012_score &
./vis in/0013.txt out/0013.txt >> out/0013_score &
./vis in/0014.txt out/0014.txt >> out/0014_score &
./vis in/0015.txt out/0015.txt >> out/0015_score &
./vis in/0016.txt out/0016.txt >> out/0016_score &
./vis in/0017.txt out/0017.txt >> out/0017_score &
./vis in/0018.txt out/0018.txt >> out/0018_score &
./vis in/0019.txt out/0019.txt >> out/0019_score &
./vis in/0020.txt out/0020.txt >> out/0020_score &
./vis in/0021.txt out/0021.txt >> out/0021_score &
./vis in/0022.txt out/0022.txt >> out/0022_score &
./vis in/0023.txt out/0023.txt >> out/0023_score &
./vis in/0024.txt out/0024.txt >> out/0024_score &
./vis in/0025.txt out/0025.txt >> out/0025_score &
./vis in/0026.txt out/0026.txt >> out/0026_score &
./vis in/0027.txt out/0027.txt >> out/0027_score &
./vis in/0028.txt out/0028.txt >> out/0028_score &
./vis in/0029.txt out/0029.txt >> out/0029_score &
./vis in/0030.txt out/0030.txt >> out/0030_score &
./vis in/0031.txt out/0031.txt >> out/0031_score &
./vis in/0032.txt out/0032.txt >> out/0032_score &
./vis in/0033.txt out/0033.txt >> out/0033_score &
./vis in/0034.txt out/0034.txt >> out/0034_score &
./vis in/0035.txt out/0035.txt >> out/0035_score &
./vis in/0036.txt out/0036.txt >> out/0036_score &
./vis in/0037.txt out/0037.txt >> out/0037_score &
./vis in/0038.txt out/0038.txt >> out/0038_score &
./vis in/0039.txt out/0039.txt >> out/0039_score &
./vis in/0040.txt out/0040.txt >> out/0040_score &
./vis in/0041.txt out/0041.txt >> out/0041_score &
./vis in/0042.txt out/0042.txt >> out/0042_score &
./vis in/0043.txt out/0043.txt >> out/0043_score &
./vis in/0044.txt out/0044.txt >> out/0044_score &
./vis in/0045.txt out/0045.txt >> out/0045_score &
./vis in/0046.txt out/0046.txt >> out/0046_score &
./vis in/0047.txt out/0047.txt >> out/0047_score &
./vis in/0048.txt out/0048.txt >> out/0048_score &
./vis in/0049.txt out/0049.txt >> out/0049_score &
./vis in/0050.txt out/0050.txt >> out/0050_score &
./vis in/0051.txt out/0051.txt >> out/0051_score &
./vis in/0052.txt out/0052.txt >> out/0052_score &
./vis in/0053.txt out/0053.txt >> out/0053_score &
./vis in/0054.txt out/0054.txt >> out/0054_score &
./vis in/0055.txt out/0055.txt >> out/0055_score &
./vis in/0056.txt out/0056.txt >> out/0056_score &
./vis in/0057.txt out/0057.txt >> out/0057_score &
./vis in/0058.txt out/0058.txt >> out/0058_score &
./vis in/0059.txt out/0059.txt >> out/0059_score &
./vis in/0060.txt out/0060.txt >> out/0060_score &
./vis in/0061.txt out/0061.txt >> out/0061_score &
./vis in/0062.txt out/0062.txt >> out/0062_score &
./vis in/0063.txt out/0063.txt >> out/0063_score &
./vis in/0064.txt out/0064.txt >> out/0064_score &
./vis in/0065.txt out/0065.txt >> out/0065_score &
./vis in/0066.txt out/0066.txt >> out/0066_score &
./vis in/0067.txt out/0067.txt >> out/0067_score &
./vis in/0068.txt out/0068.txt >> out/0068_score &
./vis in/0069.txt out/0069.txt >> out/0069_score &
./vis in/0070.txt out/0070.txt >> out/0070_score &
./vis in/0071.txt out/0071.txt >> out/0071_score &
./vis in/0072.txt out/0072.txt >> out/0072_score &
./vis in/0073.txt out/0073.txt >> out/0073_score &
./vis in/0074.txt out/0074.txt >> out/0074_score &
./vis in/0075.txt out/0075.txt >> out/0075_score &
./vis in/0076.txt out/0076.txt >> out/0076_score &
./vis in/0077.txt out/0077.txt >> out/0077_score &
./vis in/0078.txt out/0078.txt >> out/0078_score &
./vis in/0079.txt out/0079.txt >> out/0079_score &
./vis in/0080.txt out/0080.txt >> out/0080_score &
./vis in/0081.txt out/0081.txt >> out/0081_score &
./vis in/0082.txt out/0082.txt >> out/0082_score &
./vis in/0083.txt out/0083.txt >> out/0083_score &
./vis in/0084.txt out/0084.txt >> out/0084_score &
./vis in/0085.txt out/0085.txt >> out/0085_score &
./vis in/0086.txt out/0086.txt >> out/0086_score &
./vis in/0087.txt out/0087.txt >> out/0087_score &
./vis in/0088.txt out/0088.txt >> out/0088_score &
./vis in/0089.txt out/0089.txt >> out/0089_score &
./vis in/0090.txt out/0090.txt >> out/0090_score &
./vis in/0091.txt out/0091.txt >> out/0091_score &
./vis in/0092.txt out/0092.txt >> out/0092_score &
./vis in/0093.txt out/0093.txt >> out/0093_score &
./vis in/0094.txt out/0094.txt >> out/0094_score &
./vis in/0095.txt out/0095.txt >> out/0095_score &
./vis in/0096.txt out/0096.txt >> out/0096_score &
./vis in/0097.txt out/0097.txt >> out/0097_score &
./vis in/0098.txt out/0098.txt >> out/0098_score &
./vis in/0099.txt out/0099.txt >> out/0099_score &

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
