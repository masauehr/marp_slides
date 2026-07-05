---
marp: true
theme: ml-forecast
paginate: true
---

<!-- _backgroundColor: "#1e3a8a" -->
<!-- _color: "#ffffff" -->
<!-- _paginate: false -->

# Claude Code を活用した
# 気象データ分析・予測モデルの開発

## 生成AI活用事例の報告

2026年7月18日　／　WXBC 第68回気象✕IT 勉強会月例会

---

# 目次

1. 生成AI活用の経緯
2. 開発したプロダクト（気象・予測ツール）
3. 農研機構データ × ml_forecast の取り組み
4. まとめ・今後の展開

---

# 生成AI活用から Claude Code による開発へ

- 約2年前より生成AIを利用したコード作成を開始。チャットベースでWebアプリの試作を実施
- その後 AI エージェントの活用方法を知り、今年3月からClaude Code での開発を開始
- チャットでの要件整理 → GitHub への push → ドキュメント化、という一連の流れを反復し、改良していく
- 半年間で **34件** のGitHubリポジトリ（毎日のデータ自動取得やグラフ化、アプリ、ニュース検索等）を作成

> 天気図・発電量予測・電力データ分析・ローカルLLM比較など、実用ニーズに応じてテーマを設定

<div class="cols">
<div style="text-align: center;">

![w:420](../images/claude-code-welcome.png)

</div>
<div>

**Claude Code の具体的な使い方**

- フォルダにマークダウンファイルを保存（CLAUDE.md、plan.mdなど）し、AIに読ませて開発
- チャットで指示を出しAIが直接pythonコードを書いて保存
- チャットの内容をまとめさせてマニュアル化

</div>
</div>

---

# チャットでの開発 vs Claude Code（AIエージェント）

![w:1100](../images/chat-vs-agent-comparison.svg)

---

# AIへサンプルアプリを読ませて開発（応用、高機能化）

- WXBC「気象データ分析チャレンジ」にて Python・気象データの取り扱い・機械学習の基礎を習得
- 同講座を通じて**農研機構メッシュ農業気象データ（AMD）**の存在を確認
- 黒良氏の Note 連載記事を参考に GRIB2 データの読み込み処理と天気図作成スクリプトを実装
- 気象台職員のwebアプリのコード（javascript）をAIに読ませて、webアプリを作成
- 公開されている教材コードをベースに、Claude Code で機能追加・改修を実施

> 教材・サンプルコードを土台として、Claude Code と共に機能を拡張していく開発スタイル

---

<!-- _backgroundColor: "#dbeafe" -->
<!-- _color: "#1e3a8a" -->
<!-- _paginate: false -->

# 開発したプロダクト

---

# 5気象モデルによる進路予測の比較

GSM（気象庁）・ECMWF（欧州中期予報センター）・GFS（米国）・AIFS・AIFS-ENS（ECMWF AI予測）による地上気圧予報を並列表示。
例: FT=132h予報（7/10 9時JST時点）。

<div style="text-align: center;">

![w:1150](../images/typhoon_multi070412.png)

</div>

> GSM を含む5モデル比較表示は独自開発。台風接近時の進路確認に活用している

---

# 気象レーダー・衛星画像表示アプリ

<div class="cols">
<div>

- 気象情報表示webアプリのコードを Claude Code に読み込ませ、機能単位に分割したサンプルアプリ集を作成
- 単機能のコードをAIに読ませて、簡単なアプリを作成し、AIで機能を追加したりバグ取りを行う
- Web アプリ・iOS アプリ・Android アプリを同時実装（Expo Goを利用、現時点ではwebアプリのみ公開）
- 既存の実装を参考に AI で機能を移植・改修する開発手法を採用

公開URL: https://masauehr.github.io/iphone-weather-app/radar

</div>
<div style="text-align: center;">

![h:480](../images/radar.png)

</div>
</div>

---

<!-- _backgroundColor: "#dbeafe" -->
<!-- _color: "#1e3a8a" -->
<!-- _paginate: false -->

# 農研機構データ × ml_forecast の取り組み

---

# 農業気象データによる太陽光発電量予測

<div class="cols">
<div>

- 農研機構メッシュ農業気象データ（AMD）: 全国をメッシュ単位で網羅する気象データ
- WXBC「アメダス解析チャレンジ」の公開コードを参考にモデルを構築
- 説明変数: 全天日射量・日照時間等の気象予報値／目的変数: 実測発電量
- 毎朝6:30に予測を自動更新し、GitHub で結果を公開・検証

| モデル | R²（OOF） | MAE (kWh/日) |
|---|---|---|
| **Random Forest** | **0.846** | **1.89** |
| Gradient Boosting | 0.840 | 1.93 |
| Ridge 回帰 | 0.813 | 2.14 |

**→ 複数モデルを比較検討し、精度が最も高い Random Forest を現行モデルに採用**

</div>
<div style="text-align: center;">

![h:300](../images/nouken_menbunpu.png)
![h:300](../images/GSR_nouken_20260705.png)

</div>
</div>

---

# ml_forecast — 自宅太陽光発電量 機械学習予測

<div class="cols">
<div>

農研機構AMD（メッシュ農業気象データ）のGSR・GSR/平年比・SSDを説明変数に、自宅の日別太陽光発電量（kWh）をRandom Forestで予測。

### 直近5日間の発電量予測（最終更新: 2026-07-05）

| 日付 | GSR | 平年比 | SSD | 天気 | v3 | v3b |
|---|---|---|---|---|---|---|
| 07/05(日) | 30.4 | 1.48 | 7.3 | 晴れ | 18.4 | 19.3 |
| 07/06(月) | 32.4 | 1.59 | 7.3 | 晴れ | 18.5 | 20.1 |
| 07/07(火) | 24.1 | 1.18 | 5.5 | 晴れ | 16.8 | 18.2 |
| 07/08(水) | 21.4 | 1.05 | 5.5 | 晴れ | 16.4 | 17.2 |
| 07/09(木) | 22.3 | 1.10 | 5.5 | 晴れ | 16.8 | 18.1 |

単位: GSR(MJ/m²)・SSD(h)・v3/v3b(kWh)　モデル: Random Forest v3（CV MAE=2.09 kWh/日）

</div>
<div style="text-align: center;">

![w:600](../images/ml_forcast_kensyo.png)

</div>
</div>

> 精度評価は継続中。日次での予測・検証サイクルを運用している

---

# 現行モデル（v3 / v3b 並行稼働）

<div class="cols" style="grid-template-columns: 3fr 2fr;">
<div>

> **2026-06-07 より v3 移行・2026-06-23 より v3b 並行稼働**

| 項目 | v3（SSDあり） | v3b（SSDなし） |
|------|-------------|--------------|
| 説明変数 | GSR・GSR/平年比・SSD（3変数） | GSR・GSR/平年比（2変数） |
| CV MAE | **2.08 kWh/日** | 2.22 kWh/日 |
| ファイル | `rf_hatuden.joblib` | `rf_hatuden_no_ssd.joblib` |

**並行稼働の理由**: SSD 予報が晴れ日に著しく過小評価（翌日予報 bias=−7.7h/day）されており、v3 の発電量予測を系統的に引き下げている可能性を検証中。

| 天気区分 | v3 MAE（翌日） | v3b MAE（翌日） |
|---------|-------------|--------------|
| 晴れ日（SSD実測 ≥ 5h） | *3.68 kWh* | **1.73 kWh** |
| 曇り日（SSD実測 < 5h） | **2.61 kWh** | 3.22 kWh |

</div>
<div style="text-align: center;">

![w:520](../images/gsr.png)

![w:520](../images/sdd.png)

</div>
</div>

---

# 運用を通じた説明変数の見直し

<div class="cols" style="grid-template-columns: 2fr 3fr;">
<div>

- 初期モデルは説明変数の選定を含めて生成AIに一任し、一定の精度を確保
- 運用開始から約1ヶ月後、予測値に異常が見られたため要因を調査
- 5日前の日射量やその移動平均など、妥当性の低い説明変数が含まれていたことが判明
- 説明変数を見直し、モデルを再構築

</div>
<div>

### モデル変遷

| バージョン | 期間 | 説明変数 | CV MAE |
|-----------|------|---------|--------|
| v1 | 〜2026-05-17 | 8変数（GSR・TMP_max・月sin/cos・GSR_5day_avg・GSR_5day_ago等） | — |
| v2 | 2026-05-18〜06-06 | 6変数（GSR・GSR_ratio・TMP_max 等） | 2.23 kWh |
| **v3** | **2026-06-07〜** | **3変数（GSR・GSR_ratio・SSD）** | **2.08 kWh** |
| v3b | 2026-06-23〜 | 2変数（GSR・GSR_ratio、SSD除外） | 2.22 kWh |

変数を絞り込むたびに精度が向上（CV MAE 2.23→2.08 kWh）

</div>
</div>

> 発電量予測は蓄電池の夜間充電判断にも活用。晴天予測時は太陽光発電を優先し、悪天候予測時は夜間電力で充電

---

<!-- _backgroundColor: "#1e3a8a" -->
<!-- _color: "#ffffff" -->
<!-- _paginate: false -->

# まとめ・今後の展開

- このプレゼンも、Marp CLIというツールをClaude Codeで使いながら自動作成
- 開発中の各ツールは、GitHubで成果をみえる化し、運用しながら継続的に改善を実施
- 電力データ分析、太陽光発電予測を毎日実行、天気図生成、ローカルLLM、ネット情報まとめなどテーマを拡張中
- 課題：職場では源内利用開始したが、AIエージェントはまだ使えない。非効率なチャット開発に逆戻り。 
- 趣味：当面はAIエージェントで何でも自動化し腕を磨く。ただし趣味の範囲。
　　　　撮影した地衣類（藻類と菌類の共生体）画像の自動分類手法の検討

<div style="text-align: center;">

![w:500](../images/marp_vscode2.png)

</div>

以上
