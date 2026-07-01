# Marp スライド作成マニュアル

## 概要

**Marp**（Markdown Presentation Ecosystem）は、Markdown ファイルをスライド（PPTX / PDF / HTML）に変換するツール。
通常の Markdown に少しの記法を追加するだけでプレゼン資料が作れる。

**Claude Code を使うことで、資料の内容作成・レイアウト調整・変換まで一貫して自動化できる。**

---

## セットアップ

### VS Code 拡張（プレビュー用・推奨）

1. VS Code の拡張機能タブで `Marp for VS Code` を検索してインストール
2. `.md` ファイルを開くと右上にプレビューボタンが表示される

### Marp CLI（変換用）

グローバルインストールは不要。`npx` で呼び出せる。

```bash
# バージョン確認（インストール済み確認）
npx @marp-team/marp-cli --version
```

---

## Markdown ファイルの書き方

### 基本テンプレート

ファイル冒頭に `---` で囲んだ **Front Matter** を書く。

```markdown
---
marp: true
theme: default
paginate: true
---

# スライド1のタイトル

本文をここに書く

---

# スライド2のタイトル

`---` でスライドを区切る

---

# スライド3
```

### Front Matter のよく使うオプション

| オプション | 説明 | 例 |
|-----------|------|-----|
| `marp: true` | Marp を有効化（**必須**） | `marp: true` |
| `theme` | テーマ名（`default` / `gaia` / `uncover` / カスタム名） | `theme: default` |
| `paginate` | ページ番号を表示 | `paginate: true` |
| `style` | インラインCSS（簡単な調整に） | `style: \|` （複数行）|

---

## スライドのレイアウト制御

### スライドごとのディレクティブ

`<!-- -->` コメント内に書く。`_` 付きは**そのスライドだけに**適用。

```markdown
<!-- _backgroundColor: "#1e3a8a" -->
<!-- _color: "#ffffff" -->
<!-- _paginate: false -->
```

| ディレクティブ | 説明 |
|--------------|------|
| `_backgroundColor: "#色コード"` | 背景色をそのスライドだけ変える |
| `_color: "#色コード"` | 文字色をそのスライドだけ変える |
| `_paginate: false` | そのスライドだけページ番号を非表示 |
| `_class: "lead"` | テーマのスタイルを切り替え（テーマ依存） |

### 画像の配置

```markdown
![bg](image.png)              <!-- 全面背景画像 -->
![bg left:40%](image.png)     <!-- 左40%を背景画像、右にテキスト -->
![bg right:50%](image.png)    <!-- 右50%を背景画像 -->
![w:800](image.png)           <!-- 幅800px でインライン表示 -->
![w:500 h:300](image.png)     <!-- 幅500 × 高300 -->
```

### 2カラムレイアウト（CSS Grid）

カスタムテーマの `.cols` クラスを使う（後述）。

```markdown
<div class="cols">
<div>

左カラムの内容

</div>
<div>

右カラムの内容

</div>
</div>
```

---

## カスタムテーマの作り方

### CSSファイルの作成

`themes/` ディレクトリにCSSファイルを作成する。

```css
/* @theme テーマ名 */
@import 'default';  /* ベーステーマを継承 */

:root {
  --color-accent: #2563eb;
  --color-bg:     #ffffff;
  --color-fg:     #1a1a2e;
  --color-muted:  #f1f5f9;
  --font-sans:    'Helvetica Neue', Arial, 'Hiragino Sans', sans-serif;
}

section {
  background: var(--color-bg);
  color: var(--color-fg);
  font-family: var(--font-sans);
  font-size: 20px;
  padding: 48px 56px;
}

h1 {
  color: var(--color-accent);
  border-bottom: 3px solid var(--color-accent);
  padding-bottom: 0.2em;
}

table { border-collapse: collapse; width: 100%; }
th    { background: var(--color-accent); color: #fff; padding: 6px 12px; }
td    { padding: 5px 12px; border-bottom: 1px solid #e2e8f0; }
tr:nth-child(even) td { background: var(--color-muted); }

/* 2カラムレイアウト */
.cols {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}
```

### Markdown でカスタムテーマを指定する

```markdown
---
marp: true
theme: テーマ名   ← CSSの /* @theme テーマ名 */ と一致させる
---
```

---

## 変換コマンド（PPTX / PDF）

### 基本コマンド

```bash
# PDF に変換
npx @marp-team/marp-cli input.md --pdf -o output.pdf

# PPTX に変換
npx @marp-team/marp-cli input.md --pptx -o output.pptx

# HTML に変換
npx @marp-team/marp-cli input.md -o output.html
```

### カスタムテーマ付きで変換（ローカルファイル参照）

```bash
npx @marp-team/marp-cli slides/input.md \
  --theme slides/themes/ml-forecast.css \
  --pdf -o slides/output.pdf \
  --allow-local-files

npx @marp-team/marp-cli slides/input.md \
  --theme slides/themes/ml-forecast.css \
  --pptx -o slides/output.pptx \
  --allow-local-files
```

> **注意**: `--allow-local-files` はローカル画像・カスタムテーマを参照するときに必要。
> 変換は画像の**相対パスが正しく解決される**ディレクトリから実行すること。

---

## 画像の埋め込みについて

### PDF・PPTX には画像が自動的に埋め込まれる

変換が成功した時点で、ローカル画像・グラフは出力ファイルに**完全に埋め込まれた状態**になる。
PDF も PPTX も単体で配布できる自己完結したファイルになる。

**PPTX の内部構造（ZIP として展開すると確認できる）:**

```
ppt/media/
  Slide-1-image-1.png   (87KB)
  Slide-2-image-1.png  (163KB)
  Slide-18-image-1.png (403KB)   ← 大きい画像も埋め込み済み
  ...（全スライド分）
```

### 画像が埋め込まれる条件

| 条件 | 必要なこと |
|------|-----------|
| **ローカル画像** | `--allow-local-files` オプションを付ける |
| **パスが正しい** | 変換実行ディレクトリからの相対パスが解決できること |
| **URL 画像** | ネット接続があれば自動でダウンロード＆埋め込み |

### 画像が欠落しているサイン

変換時に以下の警告が出た場合、その画像はスライドに入っていない。

```
[WARN] Some of the local files are missing and will be ignored.
```

対処: パスを修正するか `--allow-local-files` を追加して再変換する。

### 別プロジェクトの画像を参照するときのパス

`marp_slides/slides/` から `ml_forecast/` の画像を参照する場合:

```markdown
![w:900](../../ml_forecast/gsr_vs_actual.png)
![w:900](../../ml_forecast/images/spatial_fcst_20260627.png)
```

変換は `marp_slides/` ディレクトリから実行することで相対パスが正しく解決される。

```bash
cd /Users/masahiro/projects/marp_slides

npx @marp-team/marp-cli slides/2026-06-ml-forecast.md \
  --theme themes/ml-forecast.css \
  --pptx -o slides/2026-06-ml-forecast.pptx \
  --allow-local-files
```

---

## PPTX の編集可否について（重要な制約）

### Marp CLI の PPTX はテキスト編集ができない

Marp CLI が生成する PPTX は、各スライドを Chromium でレンダリングした**スクリーンショット画像**を PowerPoint スライドの背景として貼り付ける方式で作られている。

実際に PPTX を ZIP として展開し `ppt/slides/slide1.xml` を確認すると、テキストボックス等が入るはずの `<p:spTree>` が空で、代わりに `<p:bg>` に画像1枚（`blipFill`）が丸ごと埋め込まれているだけであることがわかる。

```xml
<p:sld ...>
  <p:cSld>
    <p:bg><p:bgPr><a:blipFill ...><a:blip r:embed="rId1"/></a:blipFill></p:bgPr></p:bg>
    <p:spTree>...（空）...</p:spTree>
  </p:cSld>
</p:sld>
```

**理由**: Marp のテーマは自由な CSS（カスタムフォント・独自レイアウト・コードハイライト等）で組まれているため、それを PowerPoint のネイティブな図形・テキストボックスへ正確に変換するのは技術的に困難。Marp CLI は「見た目の再現」を優先し、スライド全体を画像化して焼き込む実装を採用している。

**影響**:
- PowerPoint で開いてもテキストは選択・編集できない（1枚の画像として扱われる）
- レイアウト・文言・スタイルの変更ができない
- 修正は元の `.md` を直して再変換する以外に方法がない

### 編集可能な PPTX が必要な場合の代替ツール

| ツール | テキスト編集可否 | デザイン自由度 | 備考 |
|---|---|---|---|
| **Marp CLI**（本プロジェクト） | ✕（画像焼き込み） | ◎（CSS自由） | 配布用の完成品向け。見た目を確実に再現できる |
| **ppt_auto**（python-pptx） | ◎（本物のテキストボックス） | △（定型レイアウト） | [ppt_auto](../ppt_auto/) 参照。`python-pptx` が必要（AI解析版はさらに `ANTHROPIC_API_KEY` が必要） |
| **Pandoc** | ◎（本物のテキストボックス） | △〜○（`--reference-doc` 次第） | `pandoc slides.md -o slides.pptx`。Marp独自記法（Front Matter・`<!-- _xxx -->` ディレクティブ）には対応しないため、pandoc用に記法を外した版を別途用意する必要がある |

**使い分けの目安**: 「見た目重視・そのまま配布」なら Marp、「PowerPoint 上で文言・レイアウトを手直ししたい」なら ppt_auto か Pandoc を使う。

---

## Claude Code でスライドを作成させる方法

### 基本的な頼み方

Claude Code に以下のような情報を伝えるとスムーズに作れる。

#### プロンプト例 ① 新規スライド作成

```
以下の条件で Marp スライドを作成してください。

【対象ファイル】slides/2026-07-report.md
【テーマ】slides/themes/ml-forecast.css（既存のカスタムテーマを使う）
【内容】（箇条書きで伝える）
  - タイトル: 2026年7月 月次報告
  - セクション1: 先月の実績まとめ（表あり）
  - セクション2: 今月の課題と対応策
  - まとめと次のアクション
【スタイル】
  - セクション区切りスライドは _backgroundColor "#dbeafe" で薄青背景
  - タイトル・クロージングは "#1e3a8a" で濃紺背景
  - 表・箇条書き中心でシンプルに
```

#### プロンプト例 ② 既存 README をスライドに変換

```
ml_forecast/README.md の内容を Marp スライドに再構成してください。

- 出力先: slides/2026-06-ml-forecast.md
- テーマ: slides/themes/ml-forecast.css
- README の全内容を使う必要はない。発表に適した内容を選び、1スライド1トピックで構成する
- グラフ画像は ../forecast_vs_actual.png のように相対パスで参照する
```

#### プロンプト例 ③ レイアウト調整

```
slides/2026-06-ml-forecast.md のレイアウトを調整してください。

- 「交差検証」スライドのコードブロックが長くて収まっていないので、
  内容を整理してフォントサイズを下げる（<!-- style: ... --> でそのスライドだけ調整）
- 「まとめ」スライドの表にある長い文字列が折り返している。
  列幅の割合を変えるか、文字を短くする
- テーブルヘッダーのフォントが小さすぎるので themes/ml-forecast.css の th に
  font-size: 1em を追加する
```

#### プロンプト例 ④ 変換まで一括実行

```
slides/2026-06-ml-forecast.md を PPTX と PDF の両方に変換してください。
テーマ: slides/themes/ml-forecast.css
出力先: slides/ ディレクトリ（ファイル名は md と同じベース名で）
実行は /Users/masahiro/projects/ml_forecast/ から行うこと（画像の相対パス解決のため）
```

### Claude Code が得意な作業

| 作業 | Claude Code の活用方法 |
|------|----------------------|
| 内容の構成 | 「〇〇についてのスライドを作って」と伝えるだけ |
| 表の作成 | CSV・箇条書きを渡すと Markdown テーブルに整形 |
| レイアウト調整 | 「このスライドの文字が多すぎる」と指摘すると修正 |
| テーマのカスタマイズ | 「ヘッダーを大きくして」「背景を水色に」と指示 |
| 変換コマンド実行 | 「変換して」と言えばコマンドを実行する |
| 既存スライドへの追記 | 「〇〇のスライドを追加して」と言える |

---

## ml_forecast での使い方（実例）

### ディレクトリ構成

```
ml_forecast/
├── slides/
│   ├── 2026-06-ml-forecast.md      ← Marp ソースファイル
│   ├── 2026-06-ml-forecast.pdf     ← 変換済み PDF
│   ├── 2026-06-ml-forecast.pptx    ← 変換済み PPTX
│   └── themes/
│       └── ml-forecast.css         ← カスタムテーマ
├── forecast_vs_actual.png           ← スライドから ../forecast_vs_actual.png で参照
└── images/
    └── spatial_fcst_20260627.png    ← スライドから ../images/... で参照
```

### 変換コマンド（ml_forecast 用）

```bash
cd /Users/masahiro/projects/ml_forecast

# PPTX
npx @marp-team/marp-cli slides/2026-06-ml-forecast.md \
  --theme slides/themes/ml-forecast.css \
  --pptx -o slides/2026-06-ml-forecast.pptx \
  --allow-local-files

# PDF
npx @marp-team/marp-cli slides/2026-06-ml-forecast.md \
  --theme slides/themes/ml-forecast.css \
  --pdf  -o slides/2026-06-ml-forecast.pdf \
  --allow-local-files
```

### スライドの月次更新手順

1. `slides/2026-06-ml-forecast.md` を月ごとにコピー（例: `2026-07-ml-forecast.md`）
2. Claude Code に「内容を今月分に更新して」と依頼
3. 変換コマンドを実行（Claude Code に「変換して」でも可）
4. `git add slides/ && git commit -m "slides: 2026-07 月次スライド更新" && git push`

---

## よくあるトラブル

### ページ番号が消えない

セクション区切りスライドのコメントに `<!-- _paginate: false -->` を追加する。

```markdown
<!-- _backgroundColor: "#1e3a8a" -->
<!-- _color: "#ffffff" -->
<!-- _paginate: false -->   ← これを追加
```

### カスタムテーマが適用されない

- CLI では `--theme` オプションでCSSを指定する（Front Matter の `theme:` だけでは不十分）
- CSS冒頭の `/* @theme テーマ名 */` と `theme: テーマ名` が一致しているか確認

### 画像が表示されない

- `--allow-local-files` オプションが抜けていないか確認
- 変換を実行するディレクトリと、Markdown 内の相対パスが合っているか確認
- 例: `ml_forecast/` から変換する場合、`slides/` 内のMDから `../gsr_vs_actual.png` で親ディレクトリを参照できる

### スライドの内容がはみ出る

- 文字サイズを下げる: `<!-- style: section { font-size: 16px; } -->` をスライドの先頭に追加
- テーブルを2つに分割する
- 不要な行を削除して内容を絞る

---

## README → スライド変換のテンプレート

### テンプレートファイル

| ファイル | 用途 |
|---------|------|
| `templates/template.md` | 汎用スライド（タイトル〜まとめまでの骨格） |
| `templates/readme-to-slides.md` | README を発表用スライドに再構成する雛形 |

### readme-to-slides.md の使い方

1. テンプレートをコピーして日付付きのスライドファイルを作る

```bash
cp templates/readme-to-slides.md slides/YYYY-MM-DD-プロジェクト名.md
```

2. `{{...}}` のプレースホルダーを実際の内容に置き換える

| プレースホルダー | 置き換え内容 |
|----------------|------------|
| `{{プロジェクト名}}` | タイトル・ファイルパス等 |
| `{{YYYY}}{{MM}}{{DD}}` | 作成日 |
| `{{セクション1タイトル}}` | 発表の大見出し |
| `{{グラフファイル名}}` | 参照する画像のパス |

3. Claude Code に依頼する場合

```
templates/readme-to-slides.md をベースに、ml_forecast/README.md の内容を
slides/2026-06-30-ml-forecast.md として再構成してください。
- 1スライド1トピック、発表に適した内容に絞る
- 画像は ../../ml_forecast/xxx.png で参照
- 変換後 PDF・PPTX も生成すること（marp_slides/ から実行）
```

### README から再変換するときの変換コマンド

```bash
cd /Users/masahiro/projects/marp_slides

# PDF
npx @marp-team/marp-cli slides/YYYY-MM-DD-プロジェクト名.md \
  --theme themes/ml-forecast.css \
  --pdf  -o slides/YYYY-MM-DD-プロジェクト名.pdf \
  --allow-local-files

# PPTX
npx @marp-team/marp-cli slides/YYYY-MM-DD-プロジェクト名.md \
  --theme themes/ml-forecast.css \
  --pptx -o slides/YYYY-MM-DD-プロジェクト名.pptx \
  --allow-local-files
```

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-06-30 | マニュアル新規作成。ml_forecast/slides の実例をもとに整理 |
| 2026-06-30 | 「画像の埋め込みについて」セクションを追加（PPTX/PDF への自動埋め込み・条件・欠落時の対処・別プロジェクト参照パス） |
| 2026-06-30 | `templates/readme-to-slides.md` を追加。「README → スライド変換のテンプレート」セクションを追加 |
| 2026-07-01 | 「PPTX の編集可否について（重要な制約）」セクションを追加。Marp CLI の PPTX がスライド全体を画像化して埋め込む方式（テキスト編集不可）であることと、編集可能な代替ツール（ppt_auto / Pandoc）との比較表を記載 |
