#!/usr/bin/env bash
#
# md2docx.sh — Markdown（原稿・記事）から Word（.docx）を生成する
#
# Marp のスライド変換（marp CLI）と同じ発想で、pandoc を使って
# 「見出し＋地の文＋図表」の原稿 Markdown を .docx に変換する。
#
# 使い方:
#   scripts/md2docx.sh <input.md> [output.docx] [オプション]
#
# オプション:
#   --pdf            .docx に加えて確認用 PDF も出力（LibreOffice を使用）
#   --no-toc         先頭の目次を付けない
#   --toc-depth N    目次に含める見出しレベル（既定: 2）
#   --ref <file>     フォント等を定義したリファレンス docx（既定: templates/reference-ja.docx）
#
# 例:
#   scripts/md2docx.sh slides/2026-09-18-vibe-coding-article.md --pdf
#
# 前提: pandoc（必須） / soffice（--pdf と .svg 変換に必要, LibreOffice）
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---- 引数パース ----
INPUT=""
OUTPUT=""
WITH_PDF=0
TOC=1
TOC_DEPTH=2
REF_DOC="$REPO_DIR/templates/reference-ja.docx"

while [ $# -gt 0 ]; do
  case "$1" in
    --pdf)        WITH_PDF=1; shift ;;
    --no-toc)     TOC=0; shift ;;
    --toc-depth)  TOC_DEPTH="$2"; shift 2 ;;
    --ref)        REF_DOC="$2"; shift 2 ;;
    -h|--help)    sed -n '2,30p' "$0"; exit 0 ;;
    -*)           echo "不明なオプション: $1" >&2; exit 1 ;;
    *)
      if [ -z "$INPUT" ]; then INPUT="$1"
      elif [ -z "$OUTPUT" ]; then OUTPUT="$1"
      else echo "引数が多すぎます: $1" >&2; exit 1
      fi
      shift ;;
  esac
done

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
  echo "入力 Markdown が見つかりません: ${INPUT:-(未指定)}" >&2
  exit 1
fi

command -v pandoc >/dev/null 2>&1 || { echo "pandoc が必要です（brew install pandoc）" >&2; exit 1; }

INPUT_DIR="$(cd "$(dirname "$INPUT")" && pwd)"
INPUT_BASE="$(basename "$INPUT")"
STEM="${INPUT_BASE%.*}"
[ -z "$OUTPUT" ] && OUTPUT="$INPUT_DIR/$STEM.docx"

# ---- .svg 画像を .png へ変換（Word は SVG 埋め込みに弱いため） ----
# Markdown 内の  ](xxx.svg)  または  src="xxx.svg"  を拾う（bash 3.2 対応）
SVG_LIST="$(grep -oE '\]\([^)]+\.svg\)|src="[^"]+\.svg"' "$INPUT" 2>/dev/null \
  | sed -E 's/^\]\(//; s/\)$//; s/^src="//; s/"$//' | sort -u || true)"

if [ -n "$SVG_LIST" ]; then
  command -v soffice >/dev/null 2>&1 || {
    echo "SVG 画像があるため LibreOffice(soffice) が必要です" >&2; exit 1; }
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    src="$INPUT_DIR/$rel"
    [ -f "$src" ] || { echo "  ⚠ SVG が見つかりません: $rel（スキップ）" >&2; continue; }
    png="${src%.svg}.png"
    if [ ! -f "$png" ] || [ "$src" -nt "$png" ]; then
      echo "  SVG→PNG: $rel"
      soffice --headless --convert-to png --outdir "$(dirname "$src")" "$src" >/dev/null 2>&1
    fi
  done <<EOF
$SVG_LIST
EOF
fi

# ---- .svg 参照を .png に書き換えた一時 Markdown を作る ----
TMP_MD="$(mktemp -t md2docx.XXXXXX).md"
trap 'rm -f "$TMP_MD"' EXIT
sed -E 's/(\]\([^)]+)\.svg(\))/\1.png\2/g; s/(src="[^"]+)\.svg(")/\1.png\2/g' "$INPUT" > "$TMP_MD"

# ---- pandoc オプション組み立て ----
PANDOC_ARGS=(
  "$TMP_MD"
  -o "$OUTPUT"
  --resource-path="$INPUT_DIR:$INPUT_DIR/..:$REPO_DIR:$REPO_DIR/images"
)
[ -f "$REF_DOC" ] && PANDOC_ARGS+=( --reference-doc="$REF_DOC" )
if [ "$TOC" -eq 1 ]; then
  PANDOC_ARGS+=( --toc --toc-depth="$TOC_DEPTH" --metadata toc-title=目次 )
fi

echo "pandoc → $OUTPUT"
pandoc "${PANDOC_ARGS[@]}"

# ---- 確認用 PDF ----
if [ "$WITH_PDF" -eq 1 ]; then
  command -v soffice >/dev/null 2>&1 || { echo "PDF 出力には soffice が必要です" >&2; exit 1; }
  echo "soffice → ${OUTPUT%.docx}.pdf"
  soffice --headless --convert-to pdf --outdir "$(dirname "$OUTPUT")" "$OUTPUT" >/dev/null 2>&1
fi

echo "完了。Word で開いたら目次を右クリック →「フィールドの更新」でページ番号が入ります。"
