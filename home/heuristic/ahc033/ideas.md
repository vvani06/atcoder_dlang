# AHC031
https://atcoder.jp/contests/ahc031/tasks/ahc031_a

## 問題概要
完全情報ゲー。
AHC001 みたいな感じで、要求に対して十分な面積の長方形を貸し出すやつ。
AHC001 との違いは「面積が足りなくなることはない」程度の要求しか来ない代わりに「長方形の区切りを作る区切り線」の変更コストがかかる点。

## 所感
焼きなましが効きそう。
初期状態の作り方が色々できて面白そうな感じがする。
初日のパーティション設置が無料なので、そこで今後必要になる分も買っておくと良いのでは。
とは言っても、パーティションは長方形の辺としてしか購入できないのでそこまで自由度がないか。

正方形なら必要となるパーティションの長さは最小になり、正方形から遠いほど大きくできるのでそこで遊びを作ることができるか。

## ケース0で実験

面積1の四角形しか貸し出さない(最悪): 388607901
縦棒だけで毎回最適に動かす: 80001
サンプル: 42754
