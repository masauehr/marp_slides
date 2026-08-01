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

### 配色バリエーション（ml-forecast系テーマ）

`ml-forecast` をベースにした配色違いのテーマを3種類 `themes/` に用意している。**Front Matter の `theme:` 値と変換コマンドの `--theme` パスを対応するファイルにそろえるだけで切り替えられる**（この2箇所が「設定」）。

| テーマ名（`theme:` に書く値） | CSSファイル | 配色の方向性 |
|---|---|---|
| `ml-forecast`（デフォルト） | `themes/ml-forecast.css` | パステルカラフル。オフホワイト背景に紫・水色・黄色・マゼンダを要素ごとに使い分け。柔らかく上品な印象 |
| `ml-forecast-multicolor` | `themes/ml-forecast-multicolor.css` | マルチカラー。見出しに青→紫→マゼンダのグラデーション、テーブルヘッダーもグラデーション。最も賑やかで華やか |
| `ml-forecast-vivid` | `themes/ml-forecast-vivid.css` | ビビッドグラデーション。紫を基調にしたシングルアクセント、見出し下のアンダーラインのみ多色グラデーション。落ち着きと華やかさの中間 |

3つとも配色以外（レイアウト・`.cols` クラス・ダーク背景時の見出し文字色フォールバック等）の構造は共通なので、どれを選んでも既存スライドの `.md` はそのまま使い回せる。

切り替え手順:

1. 対象の `.md` の Front Matter を書き換える
   ```markdown
   theme: ml-forecast-multicolor
   ```
2. 変換コマンドの `--theme` を同じテーマのCSSに合わせる
   ```bash
   npx @marp-team/marp-cli slides/xxx.md \
     --theme themes/ml-forecast-multicolor.css --html --allow-local-files \
     --pptx --pptx-editable -o slides/xxx.pptx
   ```

`--theme` に渡すファイルと Front Matter の `theme:` 値が食い違うと意図通りに反映されないので、必ずセットで変更すること。

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

### Marp CLI の通常の PPTX（`--pptx`）はテキスト編集ができない

Marp CLI が `--pptx` オプションだけで生成する PPTX は、各スライドを Chromium でレンダリングした**スクリーンショット画像**を PowerPoint スライドの背景として貼り付ける方式で作られている。

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

### 編集可能な PPTX を作る: `--pptx-editable`（実験的機能・推奨）

Marp CLI には **`--pptx-editable`** という実験的オプションがあり、これを付けると本物の編集可能なテキストボックスを持つ PPTX が生成できる（2026-07-02 に動作確認済み）。

**仕組み**: 内部で **LibreOffice**（`soffice`）を使い、Marp がレンダリングしたHTML/CSSのレイアウト情報から、テキストボックス・図形・画像を個別のPowerPointオブジェクトとして再構築する。装飾的な図形（背景の帯や罫線等）は `FREEFORM`、実際の文章は `TEXT_BOX` として分離される。

**事前準備（初回のみ）**:

```bash
brew install --cask libreoffice
```

**使い方**:

```bash
npx @marp-team/marp-cli --pptx --pptx-editable \
  -o output.pptx input.md --allow-local-files
```

`--theme` や `--allow-local-files` など、通常の `--pptx` 変換と同じオプションを併用できる。

**動作確認結果**（`slides/2026-07-01-ai-projects-intro.md` および、Marp用に書かれていない生の `README.md` の両方でテスト済み）:
- タイトル・本文・箇条書きが正しく個別のテキストボックスとして生成される
- 画像は `PICTURE` シェイプとして配置される
- Marp用のFront Matter（`marp: true`）が無い通常のMarkdownファイルでも、`---` を区切りとしてそのまま変換できる（ただし `---` の位置が意図した区切りと一致している必要がある）

**注意点**:
- Marp公式が「実験的機能」「LibreOffice に依存し、スライドの再現性は完全には保証されない」と明記している。複雑なCSSレイアウト（多段組み・独自アニメーション等）は崩れる可能性がある
- 変換後は必ず PowerPoint で見た目を目視確認すること
- 内容が多いスライド（表・コードブロックが多い等）は、Marp自体がその通りにレンダリングするため、そのまま変換すると1スライドに情報が詰まりすぎる場合がある。元のMarkdown側で内容を絞る・スライドを分けるといった調整は引き続き必要
- **複雑な背景（多重`background-image`・`background-blend-mode`・SVGノイズ等）はLibreOfficeが正しく再構築できず崩れる**（2026-08-01、`themes/ml-forecast.css` の `hero-gradient`〔メッシュ風グラデーション＋グレイン質感〕で確認）。LibreOfficeは背景を大量の`FREEFORM`図形で近似しようとし、階段状に崩れた模様になる。**通常の`--pptx`（画像焼き込み）や`--pdf`はChromiumのスクリーンショット方式なので影響を受けず正しく表示される**——崩れるのは`--pptx-editable`のLibreOffice再構築ルートのみ
  - 対処法（該当スライドのみ画像化するハイブリッド構成）: `python-pptx` で該当スライドの既存シェイプを全削除し、Chromiumレンダリング側（`--images png` で書き出したPNG、またはPDFから`pdftoppm`で抽出したPNG）を全面画像として`add_picture`で貼り付ける。他のスライドのテキスト編集可能性はそのまま維持できる
    ```python
    from pptx import Presentation
    prs = Presentation("output.pptx")
    slide = prs.slides[0]  # 崩れるスライドのインデックス
    for shape in list(slide.shapes):
        shape._element.getparent().remove(shape._element)
    slide.shapes.add_picture("cover.png", 0, 0, width=prs.slide_width, height=prs.slide_height)
    prs.save("output.pptx")
    ```
- **グラデーション文字（`background-clip: text`）もLibreOfficeが正しく再構築できない**（2026-08-01、`themes/ml-forecast-multicolor.css` のh1見出しで確認）。CSS上は単純な`linear-gradient`＋`background-clip:text`でも、editable PPTXでは**スライドによって挙動がバラバラに崩れる**——ある見出しは黒一色の文字になり、別の見出しではグラデーションが「文字の後ろに乗る色帯（矩形）」として再構築されて文字は黒のまま、という具合。見た目のバランスが崩れて非常に見づらくなる（PDF・通常PPTXは影響なし）
  - 対処法: グラデーション文字はeditable PPTX運用と根本的に相性が悪いため、`h1`を単色（アクセントカラー1色）＋下線装飾に変更した。見出し1つ1つを画像化する部分的ハイブリッド対応は非現実的（本文と一体のテキストボックスのため）なので、この場合は**CSS側で表現をあきらめるのが確実**

**VS Code拡張版でも利用可能**: `--pptx-editable` はMarp CLI専用ではなく、`Marp for VS Code` 拡張機能にも同等の設定 `markdown.marp.pptx.editable` として存在する（`off`/`on`/`smart`の3値、デフォルトは`off`）。`.vscode/settings.json` に追記して `Marp: Export Slide Deck` を実行するだけでよい。こちらもLibreOffice Impressのインストールが必要。詳細は [VSCODE-MARP.md](VSCODE-MARP.md) の「5. PDF / PPTX へのエクスポート」内「編集可能な PPTX を出力する」節を参照。

### 編集可能な PPTX が必要な場合の選択肢まとめ

| 方法 | テキスト編集可否 | デザイン自由度 | 備考 |
|---|---|---|---|
| **Marp CLI `--pptx`**（通常） | ✕（画像焼き込み） | ◎（CSS自由） | 配布用の完成品向け。見た目を確実に再現できる |
| **Marp CLI `--pptx-editable`** / **VS Code拡張 `pptx.editable`**（実験的） | ◎（本物のテキストボックス） | ◎（Marpのテーマがそのまま反映される） | 要 LibreOffice。CLI版・VS Code拡張版どちらでも使える。**Marpのテーマ・レイアウトを維持したまま編集可能にしたい場合はこれが第一候補** |
| **ppt_auto**（python-pptx） | ◎（本物のテキストボックス） | △（定型レイアウト） | [ppt_auto](../ppt_auto/) 参照。Marpのテーマは使わず、ppt_auto独自の定型デザインになる |
| **Pandoc** | ◎（本物のテキストボックス） | △〜○（`--reference-doc` 次第） | `pandoc slides.md -o slides.pptx`。Marp独自記法（Front Matter・`<!-- _xxx -->` ディレクティブ）には対応しないため、pandoc用に記法を外した版を別途用意する必要がある |

**使い分けの目安**:
- 「見た目重視・そのまま配布」なら Marp CLI の通常の `--pptx`
- 「Marpのデザインを保ったままPowerPointで手直ししたい」なら **`--pptx-editable`**
- 「Marpのデザインにはこだわらず、定型レイアウトで確実に編集可能にしたい」なら ppt_auto か Pandoc

---

## 高度なレイアウトテクニック（2カラム・画像配置・微調整）

`slides/2026-07-01-ai-projects-intro.md` の作成・改修（2026-07-05）で確立した、`--pptx-editable` 前提の実用テクニック集。

### レイアウト情報はどこに保存されるか（重要）

PPTX/PDF のレイアウト調整は、**`.pptx` や `.pdf` ファイル自体には保存されない**。すべて元の `.md` ファイル内に、Markdown 本文＋生HTML＋インラインCSS（`style="..."` 属性）として記述されている。`.pptx`/`.pdf` は `.md` から**毎回ゼロから再生成されるビルド成果物**であり、それ自体はレイアウトの「ソース」ではない。

つまり:
- PowerPoint を開いて手動でテキストボックスの位置をドラッグ移動しても、その変更は `.pptx` ファイル内に留まり `.md` には反映されない
- 次に `.md` から再変換すると、手動修正は跡形もなく上書きされる
- レイアウトを恒久的に変えたいなら、**必ず `.md` 側を編集してから再変換する**

### `--html` フラグが必要なケース

Marp CLI はデフォルトで、生HTML中の `style` 属性など一部の属性をセキュリティ上サニタイズ（除去）する。中央寄せ（`<div style="text-align:center;">`）やグリッド比率の変更（`<div style="grid-template-columns:...">`）など、`style` 属性を効かせたい場合は変換コマンドに **`--html`** を付ける必要がある。

```bash
npx @marp-team/marp-cli slides/xxx.md \
  --theme themes/xxx.css --html \
  --pptx --pptx-editable -o slides/xxx.pptx --allow-local-files
```

付け忘れると、`style` 属性が丸ごと消えて中央寄せが効かず左詰めに戻る、比率指定が無視される等の症状が出る。

### 2カラムレイアウトの比率調整

`.cols` クラスはデフォルトで `1fr 1fr`（左右均等）だが、内容量に応じてインライン style で上書きできる。

```markdown
<div class="cols" style="grid-template-columns: 3fr 2fr;">
<div>

左カラム（表など横幅が必要な内容）

</div>
<div>

右カラム（画像など）

</div>
</div>
```

表の列見出しが折り返して行の高さが不揃いになる場合、この比率調整（表がある側を広く）で解消できることが多い。

### 画像位置の微調整（negative margin-top）

画像を通常のフロー位置より上に詰めたい場合、右カラムの div に `margin-top` をマイナス値で指定する。見出し下の罫線に画像が食い込んで線が途切れることがあるが、実用上は許容範囲。

```markdown
<div style="text-align: center; margin-top: -70px;">

![h:300](../images/example.png)

</div>
```

### 複数画像の横並び配置（flexbox）

Markdown の画像記法を複数行並べるだけだと縦積みになる。横一列に並べたい場合は生HTMLの `<img>` タグと flexbox を使う。

```html
<div style="display: flex; justify-content: center; gap: 10px;">
<img src="../images/a.png" style="height: 150px; border-radius: 4px; object-fit: cover;">
<img src="../images/b.png" style="height: 150px; border-radius: 4px; object-fit: cover;">
<img src="../images/c.png" style="height: 150px; border-radius: 4px; object-fit: cover;">
</div>
```

### 自作SVG図解を埋め込む

アイコンや矢印を使ったオリジナルの比較図・フロー図は、`images/` 配下に SVG ファイルを作成し、通常の画像と同様に `![w:1100](../images/xxx.svg)` で埋め込める。Marp（Chromium）は SVG をそのままレンダリングするため、ラスター画像同様に `--pptx-editable` 変換時にも1枚の画像として埋め込まれる。

**注意点（ループ矢印とラベルの重なり）**: ベジェ曲線の矢印に沿ってラベルテキストを配置する場合、曲線の頂点座標とラベルのX座標を十分離さないと、線がラベル文字を貫通して見た目が崩れる。3次ベジェの頂点は制御点そのものではなく `始点 + 0.75 × (制御点オフセット)` 程度になる点に注意し、ラベルはその頂点からさらに余白を空けて配置する。

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

## 作成済みスライド一覧と変換オプション

`slides/` 配下の各 Marp スライドを何のオプションで変換したか一覧化したもの。再変換する際はここを見て同じオプションを使うこと。**オプションを間違えると `style` 属性が消えて崩れる（`--html` 忘れ）、テキストが編集できなくなる（`--pptx-editable` 忘れ）等の問題が再発する。**

下表のテーマ欄はすべて `ml-forecast`（パステルカラフル/デフォルト）だが、`ml-forecast-multicolor` / `ml-forecast-vivid` に切り替えることも可能。切り替え方は上記「配色バリエーション（ml-forecast系テーマ）」セクションを参照。

| ソース `.md` | テーマ | 出力ファイル | 変換オプション | 備考 |
|---|---|---|---|---|
| `2026-06-30-marp-introduction.md` | `ml-forecast` | `.pdf` / `.pptx`（通常＝画像焼き込み） | `--theme themes/ml-forecast.css --allow-local-files` | 生HTML/style属性を使用していないため `--html` 不要 |
| `2026-06-30-ml-forecast.md` | `ml-forecast` | `.pdf` / `.pptx`（通常） | `--theme themes/ml-forecast.css --allow-local-files` | 同上 |
| `2026-06-ml-forecast.md` | `ml-forecast` | `.pdf` / `.pptx`（通常） | `--theme themes/ml-forecast.css --allow-local-files` | 同上 |
| `jma_mcp.md` | `ml-forecast` | `.pptx`（通常） | `--theme themes/ml-forecast.css --allow-local-files` | PDF未生成。`--html` 不要 |
| `tenkizu_readme.md` | `ml-forecast` | `.pdf` / `.pptx`（通常） | `--theme themes/ml-forecast.css --allow-local-files` | `--html` 不要 |
| `2026-07-01-ai-projects-intro.md` | `ml-forecast` | `uehara_ai.pdf` / `uehara_ai.pptx`（**editable**） | `--theme themes/ml-forecast.css --html --allow-local-files`（PPTXはさらに `--pptx --pptx-editable`） | **`style="..."` 属性（flexbox横並び・2カラム比率・中央寄せ等）を多用しているため `--html` が必須**。出力ファイル名がソース `.md` と異なる（`uehara_ai`）点に注意。テキスト編集可能なPPTXが必要という要望により `--pptx-editable` を使用（要 LibreOffice） |
| `2026-07-01-ai-projects-intro-note.md` | — | 変換しない | — | note.com 投稿用に手動整形したMarkdown。Marp変換の対象外（frontmatterなし） |
| `2026-09-18-vibe-coding.md` | `ml-forecast` | `.pdf` / `.pptx`（**editable**） | `--theme themes/ml-forecast.css --html --allow-local-files`（PPTXはさらに `--pptx --pptx-editable`） | `2026-07-01-ai-projects-intro.md` をベースに、WXBC人材育成WG全体会合（2026-09-18話題提供）向けにタイトル・概要・結論を変更した派生版。新セクション「バイブコーディングとは」を追加。`.cols` 等のstyle属性を使用しているため `--html` 必須 |

**`uehara_ai` の完全な再生成コマンド:**

```bash
cd /Users/masahiro/projects/marp_slides

# PDF
npx @marp-team/marp-cli slides/2026-07-01-ai-projects-intro.md \
  --theme themes/ml-forecast.css --html \
  --pdf -o slides/uehara_ai.pdf --allow-local-files

# PPTX（編集可能）
npx @marp-team/marp-cli slides/2026-07-01-ai-projects-intro.md \
  --theme themes/ml-forecast.css --html \
  --pptx --pptx-editable -o slides/uehara_ai.pptx --allow-local-files
```

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-06-30 | マニュアル新規作成。ml_forecast/slides の実例をもとに整理 |
| 2026-06-30 | 「画像の埋め込みについて」セクションを追加（PPTX/PDF への自動埋め込み・条件・欠落時の対処・別プロジェクト参照パス） |
| 2026-06-30 | `templates/readme-to-slides.md` を追加。「README → スライド変換のテンプレート」セクションを追加 |
| 2026-07-01 | 「PPTX の編集可否について（重要な制約）」セクションを追加。Marp CLI の PPTX がスライド全体を画像化して埋め込む方式（テキスト編集不可）であることと、編集可能な代替ツール（ppt_auto / Pandoc）との比較表を記載 |
| 2026-07-02 | Marp CLIに実験的機能 `--pptx-editable` があり、LibreOffice（要`brew install --cask libreoffice`）を使うことで本物の編集可能なテキストボックスを持つPPTXを生成できることを確認・追記。Marp用のFront Matterが無い生のREADME.mdでも変換できることを確認。比較表・使い分けの目安を更新（Marpのデザインを保ったまま編集したい場合の第一候補として案内） |
| 2026-07-02 | `--pptx-editable` はMarp CLI専用ではなく、`Marp for VS Code` 拡張機能にも同等の設定 `markdown.marp.pptx.editable`（off/on/smart）として存在することを確認・追記。VSCODE-MARP.mdに設定手順を追加し、比較表の表記をCLI/VS Code拡張両対応に更新 |
| 2026-07-05 | 「高度なレイアウトテクニック（2カラム・画像配置・微調整）」セクションを追加。`slides/2026-07-01-ai-projects-intro.md` の作成・改修作業で確立した手法（レイアウト情報は`.md`のみに存在しPPTX/PDFはビルド成果物であること、`--html`フラグが必要なケース、`.cols`比率調整、negative margin-topでの画像位置調整、flexboxでの複数画像横並び、自作SVG図解の埋め込みと矢印・ラベル重なり回避）を記載 |
| 2026-07-20 | 「作成済みスライド一覧と変換オプション」セクションを追加。`slides/` 配下の各ソース`.md`について使用テーマ・`--html`要否・`--pptx-editable`要否を一覧表で記録。`uehara_ai.pptx`変換時に`--html`忘れでスタイルが崩れる不具合が発生した実例を踏まえ、再変換時の参照先として整備 |
| 2026-07-28 | `2026-09-18-vibe-coding.md` を追加。`2026-07-01-ai-projects-intro.md` をベースに、WXBC人材育成WG全体会合向けにタイトル・概要・結論を差し替えた派生版。「作成済みスライド一覧」に行を追加 |
| 2026-08-01 | `themes/ml-forecast.css` の配色をパステルカラフルに刷新。配色違いの `themes/ml-forecast-multicolor.css`（マルチカラー）・`themes/ml-forecast-vivid.css`（ビビッドグラデーション）を追加し、「配色バリエーション（ml-forecast系テーマ）」セクションで Front Matter の `theme:` 値と `--theme` パスを揃えることで切り替えられる方法を記載。また `2026-09-18-vibe-coding.md` のスライド10・13で `--html` フラグ未指定によりflexbox横並び画像が縦積みになり画面外にはみ出す不具合を修正し、画像サイズを拡大 |
| 2026-08-01 | 表紙・まとめ等の全面色スライド用に `hero-gradient`/`hero-geo`/`hero-side`/`hero-diagonal` の4クラスを `themes/ml-forecast.css` に追加（`<!-- _class: hero-xxx -->` で切り替え）。実装中、Marpの出力はSVG `foreignObject` 経由のため `::before`/`::after` 疑似要素が描画されないことを確認し、`background-image` の複数レイヤー（`radial-gradient` 重ね・角度付き `linear-gradient` のハードエッジ）で代替する方式を確立。その後 `hero-gradient` をメッシュ風グラデーション＋SVGグレイン質感にリッチ化し、他3パターンにも同じグレインと内部しみグラデーションを追加。`vibe-coding.md` の表紙・まとめに `hero-gradient` を適用したところ、`--pptx-editable`（LibreOffice再構築）が複雑な背景を正しく処理できず崩れる不具合を発見（詳細は「編集可能な PPTX を作る」節の注意点を参照）。該当2枚のみ `python-pptx` で画像焼き込みに差し替えるハイブリッド対処法を確立・適用 |
| 2026-07-28 | `2026-09-18-vibe-coding.md` に3枚追加：「開発サイクル」（`slides/開発サイクル_ポンチ絵.svg` を `images/dev_cycle.svg` にコピーして使用）、「ml_forecast のきっかけ」（WXBC「アメダス気象データ分析チャレンジ」教材の散布図を `images/wxbc_challenge_scatter.png` として追加）、「グラフからデータを読み取る仕組み」（`ml_forecast/data/hatuden/` のアプリ棒グラフを切り出し `images/hatuden_app_chart.png` として追加）。概要スライドは目次より前に配置し、経緯スライドは分割してオーバーフローを解消 |
| 2026-07-28 | `2026-09-18-vibe-coding.md` を再編集：①「開発サイクル」の単独スライドを廃止し、SVGを「生成AI活用からClaude Codeによる開発へ」スライド内の2カラムに統合、②「衛星画像・レーダー表示アプリ」のタイトルを「衛星画像・レーダー表示アプリ、潮位観測表示アプリを開発」に変更し、`--pptx-editable`変換後にPowerPointへ手動貼付されていた潮位観測アプリのスクリーンショットを`ppt/media/image4.jpeg`から抽出して`images/tide_viewer.jpeg`として`.md`側に取り込み、公開URL（tide_viewer）も追加、③「ml_forecast のきっかけ」に`slides/気温と電力の関係.png`を`images/temp_power_scatter.png`としてコピーし既存散布図の左に並べて表示、④「農業気象データによる太陽光発電量予測」と「教師データ（太陽光発電量）の取得をAIで解決」の順序を入れ替え、⑤まとめスライドの `<div class="cols">` タグ不整合（地衣類画像削除後の残骸）を修正し、`jma_mcp/README.md`「社内活用：RAGチャットボット vs MCPサーバー」の比較内容を踏まえてRAG開発着手の方針を追記 |
| 2026-07-28 | ユーザーが `2026-09-18-vibe-coding.pptx` をPowerPoint上で直接編集したため、その内容を `.md` に逆反映：「農研機構データ×ml_forecastの取り組み」divierを「農研機構メッシュ農業気象データ×AIによる機会学習の取り組み」に、「ml_forecast のきっかけ」を「取り組みのきっかけ」に改題し、「教師データ（太陽光発電量）の取得をAIで解決」の3番目の箇条書きを「画像データから発電量を読み取る仕組みと手入力で発電量を追加するアプリ（Jupyter Notebook）を作成し、日々の精度検証にも活用」に差し替え。目次も新タイトルに合わせて更新。**判明した制約**: `dev_cycle.svg`（開発サイクル図）は `--pptx-editable` 変換時にLibreOfficeがSVGをピクチャとして埋め込めず、生成された`.pptx`のスライド4には画像が入らない（PDFでは正しく表示される）。SVGを使うスライドをeditable PPTXで配布する場合は要注意 |
| 2026-07-28 | ユーザーが再度 `.md` を直接編集（スライド4から最終箇条書きを削除、「5気象モデル」の中黒を除去等）した状態を起点に3点対応：①誤字「機会学習」を「機械学習」に修正（目次・divider見出しの2箇所）、②「Claude Codeの具体的な使い方」と「チャットでの開発 vs Claude Code」の順序を入れ替え（後者を先に）、③「衛星画像・レーダー表示アプリ、潮位観測表示アプリを開発」で縦積みだった`radar.png`と`tide_viewer.jpeg`をflexboxで横並び（各`height:320px`）に変更 |
| 2026-07-29 | `dev_cycle.svg`（開発サイクル図）を「生成AI活用からClaude Codeによる開発へ」（スライド4）から「私にとってのバイブコーディング」（スライド21、タイトルを「vibe coding X GitHub 私の開発スタイル」に改題）へ移動。スライド21の`marp_vscode2.png`はdev_cycle.svgに置き換え、スライド4は画像なしの単一カラム箇条書きに戻した。**制約の再確認**: 移動先のスライド21でも同じくSVGが`--pptx-editable`変換で埋め込まれず、`.pptx`側は空白のまま（PDF版は正常）。根本対応にはSVGの事前PNG化が必要 |
| 2026-07-30 | ユーザーが `.md` を直接編集（概要文の書き直し、発表者名追加、天気図・現行モデルスライドへの補足コメント追加等）した状態を起点に対応：①タイトルスライド末尾に発表者名の行を追加した際、直後の`---`との間に空行がなくCommonMarkのSetextヘッダーとして解釈されスライドが1枚統合されてしまうバグを発見・修正（空行を挿入し22枚構成に復元）、②`slides/開発サイクル_ポンチ絵.svg`（ユーザーがラベル文字を拡大・viewBox拡大して更新）を`images/dev_cycle.svg`に再コピーしスライド21に反映、③「衛星画像・レーダー表示アプリ」の`radar.png`・`tide_viewer.jpeg`を大幅拡大（`height:320px`→`430px`、カラム比も3fr:4frに調整して文字とのバランスを確保）、④「ml_forecast — 自宅太陽光発電量 機械学習予測」の右側画像`ml_forcast_kensyo.png`に「太陽光発電量予測の検証」のキャプションを追加。**教訓**: Markdown本文に読点を含む1行を追加する際は、直後の`---`区切りとの間に必ず空行を残すこと（ないとSetextヘッダー化してスライドが意図せず結合する） |
| 2026-07-30 | タイトルスライドの発表者名「上原政博（沖縄気象台　WXBC個人会員）」を、通常のテキスト行（左寄せ）から `<div style="position: absolute; bottom: 40px; right: 56px; text-align: right;">` で囲んで右下配置に変更 |
| 2026-07-30 | ユーザーが「現行モデル」「vibe coding X GitHub 私の開発スタイル」の2枚に補足コメントを追加した結果テキストが溢れたため、意味を保ったまま文字数を削減：①「現行モデル」末尾の2行の注釈ブロックを1行に集約、②「vibe coding X GitHub 私の開発スタイル」は5箇条書きを簡潔化し、右カラムに追加されていたPython_AIグループの注釈をスライド末尾の引用に統合（4行→2行）。図（`dev_cycle.svg`）表示を最優先する指示に基づき、カラム比を等分から`3fr 2fr`（画像側を広く）に変更し画像幅を`w:380`→`w:480`に拡大 |
