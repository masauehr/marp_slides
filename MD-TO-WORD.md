# MD-TO-WORD.md — Markdown から Word（.docx）を生成する仕組み

Marp が「Markdown → スライド（PPTX/PDF）」を担うのに対し、
このドキュメントは **「Markdown → Word 文書（.docx）」** の仕組みを解説する。
スライドではなく**原稿案・寄稿記事・報告書**のような「読み物」を Word で欲しいときに使う。

- スライド変換の詳細 → [MANUAL.md](MANUAL.md)
- クイックリファレンス（コマンドだけ知りたい） → [MANUAL.md の該当節](MANUAL.md#markdown-から-worddocx-を生成する)
- このファイル → 変換の**内部の仕組み**と、原稿 Markdown の書き方

---

## 1. 全体像

```
原稿用 .md ──┬─(1) .svg を検出して soffice で .png 化
             │
             ├─(2) .svg 参照を .png に書き換えた一時 .md を作成
             │
             └─(3) pandoc が .md を .docx に変換
                     ├─ --reference-doc = templates/reference-ja.docx（フォント・スタイル）
                     ├─ --toc（先頭に目次フィールド）
                     └─ --resource-path（画像の相対パス解決）
                            │
                            └─(4) --pdf 指定時は soffice で確認用 PDF も出力
```

この (1)〜(4) を [`scripts/md2docx.sh`](scripts/md2docx.sh) が 1 コマンドで実行する。

```bash
scripts/md2docx.sh slides/2026-09-18-vibe-coding-article.md --pdf
```

| オプション | 意味 |
|-----------|------|
| `--pdf` | `.docx` に加えて確認用 PDF も出力（LibreOffice を使用） |
| `--no-toc` | 先頭の目次を付けない |
| `--toc-depth N` | 目次に含める見出しレベル（既定 2） |
| `--ref <file>` | 使うリファレンス docx を差し替える |

---

## 2. なぜ pandoc なのか

| 方式 | 生成物 | テキスト編集 | 日本語フォント | 備考 |
|------|--------|-------------|--------------|------|
| Marp CLI（`--pptx`） | スライド | ✗（画像焼き込み） | — | 見た目は忠実、編集不可 |
| Marp CLI（`--pptx-editable`） | スライド | ○ | △ | LibreOffice 経由、複雑な背景は崩れる |
| **pandoc（`-o x.docx`）** | **Word 文書** | **◎（本物の段落・表）** | **◎（reference-doc 次第）** | 見出し・表・引用・脚注をネイティブ要素に変換 |

pandoc は Markdown を**文書構造**（見出し階層・段落・箇条書き・表・引用・リンク）として解釈し、
それを Word のネイティブ要素（`Heading 1`、`Normal`、`Table` スタイル等）にマッピングする。
そのため出力 `.docx` は最初から手で編集できる普通の Word 文書になる。

---

## 3. 変換の流れ（スクリプトの中身）

### (1) `.svg` → `.png` 変換

Word は SVG の埋め込みが不安定なため、`.svg` 画像はすべて PNG に変換してから渡す。

スクリプトは入力 `.md` から次のパターンを拾う。

- Markdown 記法: `![説明](../images/foo.svg)`
- HTML 記法: `<img src="../images/foo.svg">`

見つかった `.svg` を、`.md` からの相対パスで解決し、同じ場所に `soffice` で `.png` を出力する。

```bash
soffice --headless --convert-to png --outdir <svgと同じフォルダ> <foo.svg>
```

既に `.png` があり、かつ `.svg` より新しければスキップする（無駄な再変換を避ける）。

### (2) 一時 Markdown の作成

元の `.md` は書き換えず、`.svg` 参照を `.png` に置換した一時ファイルを作って pandoc に渡す。

```
](../images/foo.svg)      →  ](../images/foo.png)
src="../images/foo.svg"   →  src="../images/foo.png"
```

### (3) pandoc 実行

```bash
pandoc <一時.md> -o <出力.docx> \
  --resource-path="<mdのフォルダ>:<その親>:<リポジトリ直下>:<リポジトリ>/images" \
  --reference-doc=templates/reference-ja.docx \
  --toc --toc-depth=2 --metadata toc-title=目次
```

- **`--resource-path`**: 画像の相対パス解決先を複数指定する。
  これにより原稿 `.md` を `slides/` に置いても `../images/foo.png` がそのまま解決される。
- **`--reference-doc`**: 後述。フォントとスタイルのひな型。
- **`--toc`**: 先頭に目次を挿入する（フィールド。後述）。

### (4) 確認用 PDF（`--pdf` 指定時）

```bash
soffice --headless --convert-to pdf --outdir <出力フォルダ> <出力.docx>
```

レイアウト確認用。最終的な体裁は Word で開いて確認すること
（LibreOffice と Word ではフォントメトリクスや改ページ位置が微妙に異なる）。

---

## 4. `templates/reference-ja.docx` の役割

pandoc の `--reference-doc` は、**「このファイルのスタイル定義を使って出力しろ」** という指定。
段落スタイル・見出しスタイル・表スタイル・既定フォント・余白などをここから引き継ぐ。

### 何を変えてあるか

pandoc 標準のリファレンス docx（`pandoc --print-default-data-file reference.docx` で取得できる）は
欧文フォント（Calibri / Cambria）前提で、日本語の見出しが細く見えることがある。
そこで `word/theme/theme1.xml` の日本語フォント指定を**游ゴシック**に統一してある。

```xml
<!-- 変更前 -->
<a:font script="Jpan" typeface="游ゴシック Light"/>   <!-- majorFont: 見出し -->
<a:font script="Jpan" typeface="游明朝"/>             <!-- minorFont: 本文 -->

<!-- 変更後 -->
<a:font script="Jpan" typeface="游ゴシック"/>
<a:font script="Jpan" typeface="游ゴシック"/>
```

### 作り直し・カスタマイズ

**方法 A（かんたん）**: `templates/reference-ja.docx` を Word で開き、
スタイル（`標準`・`見出し 1`〜）のフォントや行間を変更して**上書き保存**する。
以降の変換に反映される。

**方法 B（テーマから作り直す）**:

```bash
tmp=$(mktemp -d); cd "$tmp"
pandoc --print-default-data-file reference.docx > ref.docx
unzip -q ref.docx -d ref
# ref/word/theme/theme1.xml の script="Jpan" のフォント名を編集
cd ref && zip -q -X -r ../reference-ja.docx '[Content_Types].xml' _rels docProps word
cp ../reference-ja.docx <リポジトリ>/templates/
```

---

## 5. 目次（TOC）について

`--toc` で挿入される目次は Word の**フィールド**（`\o "1-2"` の TOC フィールド）。
pandoc は目次の「枠」だけを作り、ページ番号は入れない。

> Word で開いたあと、目次を右クリック →「フィールドの更新」→「目次全体を更新する」で
> 見出しとページ番号が展開される。

LibreOffice が出力する確認用 PDF では、この更新が走らないため**目次が空に見える**。
これは不具合ではない。目次が不要なら `--no-toc` を付ける。

---

## 6. 原稿用 Markdown の書き方

### スライド `.md` とは別ファイルにする

Marp のスライド `.md` をそのまま pandoc に渡すと、

- スライド区切りの `---` が**水平線**として大量に出力される
- Front Matter（`marp: true` 等）や `<!-- _class: ... -->` が意図せず残る／消える
- 2 カラム用の `<div class="cols">` はそのまま HTML ブロックとして扱われ体裁が崩れる

ため、**読み物用の `.md` を別に用意する**。スライドの箇条書きを地の文に言い換えるイメージ。
（例: [`slides/2026-09-18-vibe-coding.md`](slides/2026-09-18-vibe-coding.md) を元にした
[`slides/2026-09-18-vibe-coding-article.md`](slides/2026-09-18-vibe-coding-article.md)）

### 記法と Word 要素の対応

| Markdown | Word での結果 |
|----------|--------------|
| `# 見出し` / `## ` / `### ` | 見出し 1 / 2 / 3 スタイル |
| 空行区切りの段落 | 本文（`標準`）段落 |
| `- 箇条書き` / `1. 番号` | 箇条書き / 段落番号 |
| `` `コード` `` / ` ```ブロック``` ` | 等幅フォント |
| `| 表 | 記法 |` | 本物の Word の表 |
| `> 引用` | 引用スタイル |
| `[表示文字](URL)` | ハイパーリンク |
| `**強調**` / `*斜体*` | 太字 / 斜体 |
| `![キャプション](path.png)` | 図＋キャプション段落 |
| `![キャプション](path.png){width=60%}` | 図の幅を本文幅の 60% に |

### 図の幅指定

pandoc 拡張の属性記法で幅を指定できる。指定しないと画像は原寸（本文幅で頭打ち）。

```markdown
![開発サイクル](../images/dev_cycle.png){width=55%}
```

横並びにしたいペア画像も、Word では**縦に積まれる**。
キャプションはそれぞれの画像に個別に付けること（「左:… 右:…」は使わない）。

---

## 7. Marp（スライド）と pandoc（Word）の使い分け

| 欲しいもの | 使うツール | 入力 |
|-----------|-----------|------|
| 発表スライド（投影用） | Marp CLI | スライド `.md`（`marp: true`） |
| 編集可能なスライド | Marp CLI `--pptx-editable` | 同上 |
| 原稿案・寄稿記事・報告書（読み物） | `scripts/md2docx.sh`（pandoc） | 原稿用 `.md` |
| 定型 PPTX（表紙・目次・本文） | [ppt_auto](../ppt_auto/) | Markdown / JSON |

---

## 8. トラブルシュート

| 症状 | 原因 / 対処 |
|------|------------|
| 画像が出ない | パスが `.md` からの相対になっているか確認。`--resource-path` に無いフォルダは解決されない |
| SVG が出ない・崩れる | `soffice`（LibreOffice）が未インストール。`brew install --cask libreoffice` |
| 目次が空（PDF） | 仕様。Word で「フィールドの更新」。不要なら `--no-toc` |
| 日本語が明朝で細い | `--reference-doc` が効いていない。`templates/reference-ja.docx` の存在を確認 |
| `---` が水平線だらけ | スライド `.md` を直接変換している。原稿用 `.md` を用意する |
| フォントを変えたい | 「4. reference-ja.docx の役割」の方法 A |
| `pandoc: command not found` | `brew install pandoc` |

---

## 9. Claude Code での頼み方

```
slides/2026-09-18-vibe-coding.md を元に、寄稿記事風の解説文にして
scripts/md2docx.sh で Word 原稿案を作って。図もスライドのものを使って。
```

スライドの箇条書きを地の文に言い換え、図をキャプション付きで本文に配置し、
`scripts/md2docx.sh` で `.docx`（＋確認用 PDF）まで生成する、という流れを一括で依頼できる。
