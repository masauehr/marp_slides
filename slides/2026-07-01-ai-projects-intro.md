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

2026年7月　／　WXBC月例会

---

# アジェンダ

1. 生成AI活用の経緯
2. 開発したプロダクト（気象・予測ツール）
3. 農研機構データ × ml_forecast の取り組み
4. まとめ・今後の展開

---

# 生成AI活用から Claude Code による開発へ

- 約2年前より生成AIを利用したコード作成を開始。チャットベースでWebアプリの試作を実施
- その後 AI エージェントの活用方法を知り、CLAUDE.md・plan.md を用いた Claude Code での開発フローを導入
- チャットでの要件整理 → GitHub への push → ドキュメント化、という一連の流れを反復
- 半年間で **34件** のリポジトリを作成

> 天気図・発電量予測・電力データ分析・ローカルLLM比較など、実用ニーズに応じてテーマを設定

---

# 学習教材と参考資料

- WXBC「気象データ分析チャレンジ」にて Python・気象データの取り扱い・機械学習の基礎を習得
- 同講座を通じて**農研機構メッシュ農業気象データ（AMD）**の存在を確認
- 黒良氏の Note 連載記事を参考に GRIB2 データの読み込み処理を実装
- 公開されている教材コードをベースに、Claude Code で機能追加・改修を実施

> 教材・サンプルコードを土台として、Claude Code と共に機能を拡張していく開発スタイル

---

<!-- _backgroundColor: "#dbeafe" -->
<!-- _color: "#1e3a8a" -->
<!-- _paginate: false -->

# 開発したプロダクト

---

# 3気象モデルによる進路予測の比較

GSM（気象庁）・ECMWF（欧州中期予報センター）・GFS（米国）による地上気圧予報を並列表示。
例: 2026年5月29日12UTC初期値、84時間予報。

![w:300](../../claude_writing/examples/images/2026052912_FT084h_GSM_SurfacePressure.png)
![w:300](../../claude_writing/examples/images/2026052912_FT084h_ECM_SurfacePressure.png)
![w:300](../../claude_writing/examples/images/2026052912_FT084h_GFS_SurfacePressure.png)

> GSM を含む3モデル比較表示は独自開発。台風接近時の進路確認に活用している

---

# 気象レーダー・衛星画像表示アプリ

- 公開されている実装を Claude Code に読み込ませ、機能単位に分割したアプリを開発
- Web アプリ・iOS アプリ・Android アプリを実装（現時点では非公開）
- 既存の実装を参考に AI で機能を移植・改修する開発手法を採用

<!-- TODO: mobile_app のスクリーンショットを用意し次のように差し替える
![w:600](../../mobile_app/screenshots/radar.png) -->

公開URL: https://masauehr.github.io/iphone-weather-app/radar

---

<!-- _backgroundColor: "#dbeafe" -->
<!-- _color: "#1e3a8a" -->
<!-- _paginate: false -->

# 農研機構データ × ml_forecast の取り組み

---

# 農業気象データによる太陽光発電量予測

- 農研機構メッシュ農業気象データ（AMD）: 全国をメッシュ単位で網羅する気象データ
- WXBC「アメダス解析チャレンジ」の公開コードを参考にモデルを構築
- 説明変数: 全天日射量・日照時間等の気象予報値／目的変数: 実測発電量
- 手法: **Random Forest**。毎朝6:30に予測を自動更新し、GitHub で結果を公開・検証

---

# 予測値と実測値の日次検証

![w:600](../../claude_writing/examples/images/forecast_vs_actual.png)
![w:600](../../claude_writing/examples/images/monthly_avg_generation.png)

> 精度評価は継続中。日次での予測・検証サイクルを運用している

---

# 運用を通じた説明変数の見直し

- 初期モデルは説明変数の選定を含めて生成AIに一任し、一定の精度を確保
- 運用開始から約1ヶ月後、予測値に異常が見られたため要因を調査
- 5日前の日射量やその移動平均など、妥当性の低い説明変数が含まれていたことが判明
- 説明変数を見直し、モデルを再構築

> 発電量予測は蓄電池の夜間充電判断にも活用。晴天予測時は太陽光発電を優先し、悪天候予測時は夜間電力で充電

---

<!-- _backgroundColor: "#1e3a8a" -->
<!-- _color: "#ffffff" -->
<!-- _paginate: false -->

# まとめ・今後の展開

- 開発中の各ツールは、運用しながら継続的に改善を実施
- ローカルLLM比較・電力データ分析についても並行して取り組み中
- 今後の課題: 撮影した地衣類（コケ類）画像の自動分類手法の検討

以上
