# VS Code + Marp だけでスライドを作る

CLI・Claude Code なしで、VS Code と Marp 拡張のみを使って  
Markdown → PDF / PPTX を生成する手順をまとめる。

---

## 1. セットアップ

### 拡張機能のインストール

VS Code の拡張機能タブで `Marp for VS Code`（`marp-team.marp-vscode`）を検索してインストール。

### ワークスペース設定

プロジェクトルートに `.vscode/settings.json` を作成：

```json
{
  "markdown.marp.themes": [
    "./themes/ml-forecast.css"
  ],
  "markdown.marp.enableHtml": true,
  "markdown.marp.exportType": "pdf"
}
```

| 設定キー | 内容 |
|---------|------|
| `markdown.marp.themes` | カスタムテーマ CSS の登録（ワークスペースルートからの相対パス） |
| `markdown.marp.enableHtml` | HTML 記法・ローカルファイル参照を許可 |
| `markdown.marp.exportType` | デフォルトのエクスポート形式（`pdf` / `pptx` / `html`） |

> **注意**: 設定変更後は `Cmd+Shift+P` → `Developer: Reload Window` でリロードする。

---

## 2. MD ファイルの作成

### Front Matter（必須）

ファイル先頭に必ず記述する。これがないと Marp として認識されない。

```markdown
---
marp: true
theme: ml-forecast
paginate: true
---
```

| オプション | 説明 |
|-----------|------|
| `marp: true` | Marp を有効化（**必須**） |
| `theme` | テーマ名（CSS の `/* @theme テーマ名 */` と一致させる） |
| `paginate` | ページ番号を表示 |

### スライドの区切り

`---` でスライドを区切る。

```markdown
---
marp: true
theme: ml-forecast
paginate: true
---

# スライド1

内容

---

# スライド2

内容
```

### スライドごとのスタイル指定

`<!-- -->` コメントで、そのスライドだけに適用するスタイルを指定できる。

```markdown
<!-- _backgroundColor: "#1e3a8a" -->
<!-- _color: "#ffffff" -->
<!-- _paginate: false -->
```

---

## 3. スニペット（テンプレート入力補助）

`.md` ファイル内で以下の prefix を入力して `Tab` キーで展開。

| prefix | 展開内容 |
|--------|---------|
| `marp` | Front Matter + タイトルスライド（濃紺）全体骨格 |
| `marpsec` | セクション区切りスライド（薄青） |
| `marpend` | クロージングスライド（濃紺） |
| `marpdiv` | スライド区切り `---` + タイトル |

> 候補が出ない場合は `Ctrl+Space` で IntelliSense を呼び出す。

---

## 4. プレビュー確認

`.md` ファイルを開いた状態で、右上の **プレビューボタン**（または `Cmd+Shift+V`）をクリック。  
編集内容がリアルタイムでプレビューに反映される。

---

## 5. PDF / PPTX へのエクスポート

```
Cmd+Shift+P → Marp: Export Slide Deck
```

保存ダイアログでファイル名と形式（`.pdf` / `.pptx` / `.html`）を選んで保存。

> デフォルト形式は `markdown.marp.exportType` で設定した値になる。

### 編集可能な PPTX を出力する（実験的機能）

`markdown.marp.pptx.editable` 設定で、テキストボックス等を編集できる本物のPPTXを出力できる（CLI版の `--pptx-editable` と同等機能）。

```json
{
  "markdown.marp.pptx.editable": "smart"
}
```

| 値 | 内容 |
|----|------|
| `off`（デフォルト） | 非編集PPTX（画像埋め込み）。見た目の再現性・スピーカーノート対応を優先 |
| `on` | 常に編集可能PPTXで出力。スライド内容によっては変換失敗やレイアウト崩れの可能性あり |
| `smart` | 編集可能PPTXを試み、失敗時は非編集PPTXにフォールバック |

> **事前準備**: 対応ブラウザに加えて **LibreOffice Impress** のインストールが必要（`brew install --cask libreoffice`）。CLI版と同じ制約（実験的機能、変換結果の再現性はLibreOfficeのバージョン依存）が当てはまる。

---

## 6. スライドに収まらない場合の対処

### ① そのスライドだけフォントを小さくする

```markdown
<!-- style: section { font-size: 16px; } -->

# スライドタイトル

内容...
```

### ② スライドを2枚に分割する

```markdown
# 課題と対策（1/2）

- 項目1
- 項目2

---

# 課題と対策（2/2）

- 項目3
- 項目4
```

### ③ 2カラムレイアウトにする

テーマに `.cols` クラスが定義済みなので使える。

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

### 見出しをスライド幅にフィットさせる

```markdown
# <!-- fit --> この見出しはスライド幅に自動フィットする
```

### 使い分けの目安

| 状況 | 対処 |
|------|------|
| 少しだけはみ出す | ① フォントサイズを下げる |
| 内容が多くて2画面分ある | ② スライドを分割 |
| 箇条書きや比較が多い | ③ 2カラムレイアウト |
| 見出しが長い | `<!-- fit -->` を使う |

---

## 7. カスタムテーマの構成（参考）

```
marp_slides/
├── .vscode/
│   └── settings.json      ← テーマ登録・エクスポート設定
├── themes/
│   └── ml-forecast.css    ← カスタムテーマ（青ベース）
├── templates/
│   ├── template.md        ← 汎用スライドテンプレート
│   └── readme-to-slides.md
└── slides/
    └── YYYY-MM-DD-タイトル.md
```

テーマ CSS の先頭：

```css
/* @theme ml-forecast */
/* @auto-scaling true */   ← コードブロック・数式・fit見出しを自動縮小
@import 'default';
```
