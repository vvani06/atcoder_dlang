#!/bin/bash -e

ldmd2 -O -release ../src/a.d -of ./a
touch score
rm score
rm out/*
date && ./a < in/0000.txt > out/0000.txt && ./tester in/0000.txt out/0000.txt >> score
date && ./a < in/0001.txt > out/0001.txt && ./tester in/0001.txt out/0001.txt >> score
date && ./a < in/0002.txt > out/0002.txt && ./tester in/0002.txt out/0002.txt >> score
date && ./a < in/0003.txt > out/0003.txt && ./tester in/0003.txt out/0003.txt >> score
date && ./a < in/0004.txt > out/0004.txt && ./tester in/0004.txt out/0004.txt >> score
date && ./a < in/0005.txt > out/0005.txt && ./tester in/0005.txt out/0005.txt >> score
date && ./a < in/0006.txt > out/0006.txt && ./tester in/0006.txt out/0006.txt >> score
date && ./a < in/0007.txt > out/0007.txt && ./tester in/0007.txt out/0007.txt >> score
date && ./a < in/0008.txt > out/0008.txt && ./tester in/0008.txt out/0008.txt >> score
date && ./a < in/0009.txt > out/0009.txt && ./tester in/0009.txt out/0009.txt >> score
date && ./a < in/0010.txt > out/0010.txt && ./tester in/0010.txt out/0010.txt >> score
date && ./a < in/0011.txt > out/0011.txt && ./tester in/0011.txt out/0011.txt >> score
date && ./a < in/0012.txt > out/0012.txt && ./tester in/0012.txt out/0012.txt >> score
date && ./a < in/0013.txt > out/0013.txt && ./tester in/0013.txt out/0013.txt >> score
date && ./a < in/0014.txt > out/0014.txt && ./tester in/0014.txt out/0014.txt >> score
date && ./a < in/0015.txt > out/0015.txt && ./tester in/0015.txt out/0015.txt >> score
date && ./a < in/0016.txt > out/0016.txt && ./tester in/0016.txt out/0016.txt >> score
date && ./a < in/0017.txt > out/0017.txt && ./tester in/0017.txt out/0017.txt >> score
date && ./a < in/0018.txt > out/0018.txt && ./tester in/0018.txt out/0018.txt >> score
date && ./a < in/0019.txt > out/0019.txt && ./tester in/0019.txt out/0019.txt >> score
date && ./a < in/0020.txt > out/0020.txt && ./tester in/0020.txt out/0020.txt >> score
date && ./a < in/0021.txt > out/0021.txt && ./tester in/0021.txt out/0021.txt >> score
date && ./a < in/0022.txt > out/0022.txt && ./tester in/0022.txt out/0022.txt >> score
date && ./a < in/0023.txt > out/0023.txt && ./tester in/0023.txt out/0023.txt >> score
date && ./a < in/0024.txt > out/0024.txt && ./tester in/0024.txt out/0024.txt >> score
date && ./a < in/0025.txt > out/0025.txt && ./tester in/0025.txt out/0025.txt >> score
date && ./a < in/0026.txt > out/0026.txt && ./tester in/0026.txt out/0026.txt >> score
date && ./a < in/0027.txt > out/0027.txt && ./tester in/0027.txt out/0027.txt >> score
date && ./a < in/0028.txt > out/0028.txt && ./tester in/0028.txt out/0028.txt >> score
date && ./a < in/0029.txt > out/0029.txt && ./tester in/0029.txt out/0029.txt >> score
date && ./a < in/0030.txt > out/0030.txt && ./tester in/0030.txt out/0030.txt >> score
date && ./a < in/0031.txt > out/0031.txt && ./tester in/0031.txt out/0031.txt >> score
date && ./a < in/0032.txt > out/0032.txt && ./tester in/0032.txt out/0032.txt >> score
date && ./a < in/0033.txt > out/0033.txt && ./tester in/0033.txt out/0033.txt >> score
date && ./a < in/0034.txt > out/0034.txt && ./tester in/0034.txt out/0034.txt >> score
date && ./a < in/0035.txt > out/0035.txt && ./tester in/0035.txt out/0035.txt >> score
date && ./a < in/0036.txt > out/0036.txt && ./tester in/0036.txt out/0036.txt >> score
date && ./a < in/0037.txt > out/0037.txt && ./tester in/0037.txt out/0037.txt >> score
date && ./a < in/0038.txt > out/0038.txt && ./tester in/0038.txt out/0038.txt >> score
date && ./a < in/0039.txt > out/0039.txt && ./tester in/0039.txt out/0039.txt >> score
date && ./a < in/0040.txt > out/0040.txt && ./tester in/0040.txt out/0040.txt >> score
date && ./a < in/0041.txt > out/0041.txt && ./tester in/0041.txt out/0041.txt >> score
date && ./a < in/0042.txt > out/0042.txt && ./tester in/0042.txt out/0042.txt >> score
date && ./a < in/0043.txt > out/0043.txt && ./tester in/0043.txt out/0043.txt >> score
date && ./a < in/0044.txt > out/0044.txt && ./tester in/0044.txt out/0044.txt >> score
date && ./a < in/0045.txt > out/0045.txt && ./tester in/0045.txt out/0045.txt >> score
date && ./a < in/0046.txt > out/0046.txt && ./tester in/0046.txt out/0046.txt >> score
date && ./a < in/0047.txt > out/0047.txt && ./tester in/0047.txt out/0047.txt >> score
date && ./a < in/0048.txt > out/0048.txt && ./tester in/0048.txt out/0048.txt >> score
date && ./a < in/0049.txt > out/0049.txt && ./tester in/0049.txt out/0049.txt >> score
date && ./a < in/0050.txt > out/0050.txt && ./tester in/0050.txt out/0050.txt >> score
date && ./a < in/0051.txt > out/0051.txt && ./tester in/0051.txt out/0051.txt >> score
date && ./a < in/0052.txt > out/0052.txt && ./tester in/0052.txt out/0052.txt >> score
date && ./a < in/0053.txt > out/0053.txt && ./tester in/0053.txt out/0053.txt >> score
date && ./a < in/0054.txt > out/0054.txt && ./tester in/0054.txt out/0054.txt >> score
date && ./a < in/0055.txt > out/0055.txt && ./tester in/0055.txt out/0055.txt >> score
date && ./a < in/0056.txt > out/0056.txt && ./tester in/0056.txt out/0056.txt >> score
date && ./a < in/0057.txt > out/0057.txt && ./tester in/0057.txt out/0057.txt >> score
date && ./a < in/0058.txt > out/0058.txt && ./tester in/0058.txt out/0058.txt >> score
date && ./a < in/0059.txt > out/0059.txt && ./tester in/0059.txt out/0059.txt >> score
date && ./a < in/0060.txt > out/0060.txt && ./tester in/0060.txt out/0060.txt >> score
date && ./a < in/0061.txt > out/0061.txt && ./tester in/0061.txt out/0061.txt >> score
date && ./a < in/0062.txt > out/0062.txt && ./tester in/0062.txt out/0062.txt >> score
date && ./a < in/0063.txt > out/0063.txt && ./tester in/0063.txt out/0063.txt >> score
date && ./a < in/0064.txt > out/0064.txt && ./tester in/0064.txt out/0064.txt >> score
date && ./a < in/0065.txt > out/0065.txt && ./tester in/0065.txt out/0065.txt >> score
date && ./a < in/0066.txt > out/0066.txt && ./tester in/0066.txt out/0066.txt >> score
date && ./a < in/0067.txt > out/0067.txt && ./tester in/0067.txt out/0067.txt >> score
date && ./a < in/0068.txt > out/0068.txt && ./tester in/0068.txt out/0068.txt >> score
date && ./a < in/0069.txt > out/0069.txt && ./tester in/0069.txt out/0069.txt >> score
date && ./a < in/0070.txt > out/0070.txt && ./tester in/0070.txt out/0070.txt >> score
date && ./a < in/0071.txt > out/0071.txt && ./tester in/0071.txt out/0071.txt >> score
date && ./a < in/0072.txt > out/0072.txt && ./tester in/0072.txt out/0072.txt >> score
date && ./a < in/0073.txt > out/0073.txt && ./tester in/0073.txt out/0073.txt >> score
date && ./a < in/0074.txt > out/0074.txt && ./tester in/0074.txt out/0074.txt >> score
date && ./a < in/0075.txt > out/0075.txt && ./tester in/0075.txt out/0075.txt >> score
date && ./a < in/0076.txt > out/0076.txt && ./tester in/0076.txt out/0076.txt >> score
date && ./a < in/0077.txt > out/0077.txt && ./tester in/0077.txt out/0077.txt >> score
date && ./a < in/0078.txt > out/0078.txt && ./tester in/0078.txt out/0078.txt >> score
date && ./a < in/0079.txt > out/0079.txt && ./tester in/0079.txt out/0079.txt >> score
date && ./a < in/0080.txt > out/0080.txt && ./tester in/0080.txt out/0080.txt >> score
date && ./a < in/0081.txt > out/0081.txt && ./tester in/0081.txt out/0081.txt >> score
date && ./a < in/0082.txt > out/0082.txt && ./tester in/0082.txt out/0082.txt >> score
date && ./a < in/0083.txt > out/0083.txt && ./tester in/0083.txt out/0083.txt >> score
date && ./a < in/0084.txt > out/0084.txt && ./tester in/0084.txt out/0084.txt >> score
date && ./a < in/0085.txt > out/0085.txt && ./tester in/0085.txt out/0085.txt >> score
date && ./a < in/0086.txt > out/0086.txt && ./tester in/0086.txt out/0086.txt >> score
date && ./a < in/0087.txt > out/0087.txt && ./tester in/0087.txt out/0087.txt >> score
date && ./a < in/0088.txt > out/0088.txt && ./tester in/0088.txt out/0088.txt >> score
date && ./a < in/0089.txt > out/0089.txt && ./tester in/0089.txt out/0089.txt >> score
date && ./a < in/0090.txt > out/0090.txt && ./tester in/0090.txt out/0090.txt >> score
date && ./a < in/0091.txt > out/0091.txt && ./tester in/0091.txt out/0091.txt >> score
date && ./a < in/0092.txt > out/0092.txt && ./tester in/0092.txt out/0092.txt >> score
date && ./a < in/0093.txt > out/0093.txt && ./tester in/0093.txt out/0093.txt >> score
date && ./a < in/0094.txt > out/0094.txt && ./tester in/0094.txt out/0094.txt >> score
date && ./a < in/0095.txt > out/0095.txt && ./tester in/0095.txt out/0095.txt >> score
date && ./a < in/0096.txt > out/0096.txt && ./tester in/0096.txt out/0096.txt >> score
date && ./a < in/0097.txt > out/0097.txt && ./tester in/0097.txt out/0097.txt >> score
date && ./a < in/0098.txt > out/0098.txt && ./tester in/0098.txt out/0098.txt >> score
date && ./a < in/0099.txt > out/0099.txt && ./tester in/0099.txt out/0099.txt >> score

SCORE=`cat score | grep Score | awk '{sum+=$3} END {printf "%.2f\n", sum / 100}'`
echo $SCORE

DATE=`date "+%Y%m%d_%H%M%S"`
echo -e "${DATE}\t${SCORE}" >> score_history

cp score "logs/test_${DATE}"
