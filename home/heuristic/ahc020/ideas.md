# AHC019

MC Digital プログラミングコンテスト2023（AtCoder Heuristic Contest 019）

問題文: https://atcoder.jp/contests/ahc019/tasks/ahc019_a


## 考えたこと

### スコア計算

- 2つの立体で「両方とも使う」ブロックを多くできると良い
- と同時に、ブロックの体積を大きくできると良い

ブロックの堆積は大きい方が良いが、あくまで共通で使える場合に限る。

### とりあえず体積1の組み合わせから始める

最初は全てのブロックを体積1として、配置できるすべての座標に置くことを考えると始めやすそう。
余計なブロックは後から取り除く形でなんとかできるのでは。

### DFSが使えそう

ある座標から「正面」「右・左」「上・下」に移動するようなDFSを考える。
2つの立体における任意の点・方向でスタートして、2つの立体で移動できる経路のうち最大のものをとっていく。

### 体積1の残留ブロックを消す

体積が大きいブロックの組み合わせが作れたとして、シルエットに影響のない体積1のブロックがあるなら
それは純粋に取り除くことをしてしまっても良いはず。 r1, r2 の削減になる


## Diary

### 20230318
今日からコンテスト開始。東京ではオンサイトコンテストをやっているらしくて盛り上がっている。
問題文を見た限り、これは難しそう・・！ということでそっ閉じしてスプラとポケモンをやった。

### 20230319
実装に取り掛かる。とりあえず体積1のブロックを並べるだけなら簡単だろう。
「置いてはいけない座標」はシルエットから明確に割り出せるので、それ以外の座標に置けるだけ置く方針で実装。
ついでに、2パターンで共有できるブロックのIDは最大まで共有するようにしておく。これで提出。

サンプルコードをそのまま提出している人がたくさんいるっぽくて、スコアが並んでいた。自分のスコアは一応それよりは高い模様。
基本方針はサンプルコードも同じなのだけど、サンプルコードではブロックの共通をしていない分で差がついているようだ。

スコアは 11.5T ほど。

### 20230320
労働してた。体調がほんのり悪かったので早く寝た。

### 20230321
DFSでマージしていくやつの実装を進めてみる。
静的配列を使い慣れてないせいか、実装が悪いのか手元の環境でやたらとセグメンテーション違反が出て困る。
手元のエラーはコードテストでは再現しないのでとりあえずできたものを提出してみる。

11.5T => 3.0T に改善。
実行時間は1.3sくらい。 O(D^^3 * D^^3) = 7,529,536 

スコアが改善することはわかったのでこの方針は続行。
再帰実装をやめてキューでやるようにしてとりあえず回避。

今は探索を始める際の始点を若い方からで固定しているのだけど、
ここをランダムスタートにすると良いケースが出てきそうな気がするなー。
あと、2つの形で「向きが違う」パターンはまだ考慮していないので、そこらへんか。
先に「向きが違う」を検討して、その後多点スタートを考慮するのが良いかな。

実装が楽だったので、とりあえず多点というか全点スタートを試してみた。
当然TLEになる実装だけど、スコア算出だけ参考地として出しておく。

2023/03/21 05:53:34	59406829554.27 (固定)
2023/03/21 11:34:17	58039169407.51 (全点)

全然スコアに影響しない。これはランダム要素を取り入れるにしても後で良さそうだ。
ただ、多点スタートにせよ今は「できる限り大きくする」方向の貪欲でやっているのだけどこれがおいしくない可能性を感じる。
ブロックサイズが 10, 6, 3, 2 みたいなやつよりも 6, 5, 5, 5, 5 の方がスコア的には良くなるのだよな。
特に 2 のやつがたくさん、みたいに偏るのは良くなさそう。**最小ブロックサイズを最大化する** 方向で考える方が良いのかもしれない。

回転も実装してみた。実装が難しそうだな・・？と思っていたけど結構スムーズにできて天才っぽかった。
ただ、これも多点スタート同様に、現時点ではスコアに寄与する感じではない。

「体積1の残留ブロックを消す」も実装してみた。これは明確にスコアの改善につながった。

3.0T => 746.3G に改善。

「最小ブロックサイズを最大化する方向」で考えるのが目下の目標だろうか。
これを実現できれば、多点スタートにしたり回転したりの価値が相乗的に現れてくる気がする。
あとは、シルエットの形状からして「ここの座標はクリティカルネスが高い」みたいなことも表現できそうな気がする。
そういう座標に体積1のブロックがきて必須になってしまうとスコアのネックになる。

つまりクルティカルネスの高い座標を優先的にみて、
ブロックの最小サイズを幅優先探索のような要領で 1 => 2 => 3 => ... と拡げていくことができると良さそう。

2つのパターンにおいて、トータルの体積は合致している方が有利ということもありそう。
今は貪欲に体積を増やして、最終的に無駄なやつだけ削ぎ落としているけれども
なるべく同じ体積になるように仕向けることができると良さそう。

### 20230322
労働とSplatoonをしてた。

### 20230323
労働してたけど、定時で上がったので少しだけ改善するぞ。
D=5のケースみたいに図形が小さい場合はおそらく時間が大量に余っている。
そういう場合には新たに図形を作ることを時間目一杯繰り返すランダムプレイアウトを実装してみた。
手元の100ケース実行ではトータルスコアが悪化したのだけど、提出してみたらスコアが上がって結構順位も上がった。

746.3G => 559.3G。

### 20230324
労働してた。

### 20230325
頂点によっては「ここはどうでもいい」「ここは重要」みたいなのがあるので、
ブロックを伸ばす時の評価点を設けると良さそうな気がするのでやってみた。

2つの図形のうち、片方が余るというケースがそこそこあって
これがネックとなって点数が悪化しているものがいくつかみられている。
最初に削れる分を削る、という形にすると良くなるのではないか・・

### 20230326
評価式を厳密にして、ブロックをマージしながら座標の価値を前後させるようにした。

今はシルエットから考えられる最大図形からブロックを作って、
最初に余分すぎるやつを削り、最後に無駄になった部分を落とす形にしているのだけど
実は「最小図形から始めて、許容される空白を侵食する」方が良いのかもしれない。
おそらく、これだと最終的にムダなブロックができることがないし、対象の座標が最初から絞られるので計算量的にも優れている。

### 20230327
「最小図形から始める」というやつをやろうと思ったのだけど、「最大図形」と違って形状が一意じゃないよね・・ということで腰が重くなった。
今の実装はすべて初期状態からのプレイアウトなのだけど、途中で一部のブロックを破壊するタイプの山登り？をやる方がより高速に試行を回せそうな気がする。
そんなわけで実装した。かなりバグらせたのだけど、Dが大きいケースでのスコアがそこそこ改善しそうな感じになった。
逆にDが小さいケースでの戦績がプレイアウトに負け気味。ブロックを破壊する数とかを調整したらいい感じになるかも。
諸々調整したら驚くほどスコアが良くなってしまった。なんだこれは・・

# 20230328 ~ 20230331
労働のピークでほとんど何もできず。評価関数をいじったりパラメータ調整したりしてた。
