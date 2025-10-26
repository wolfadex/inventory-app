#!/usr/bin/env bash
set -e

HTML="dist/index.html"
CSS="dist/style.css"
JS="dist/elm-land.js"
TMP="$HTML.tmp"

# Copy index.html to temp file with placeholders
cp "$HTML" "$TMP"

# Replace tags with placeholders
sed -i.bak \
  -e 's|<link rel="stylesheet" href="/style.css"></link>|__INLINE_CSS__|' \
  -e 's|<script type="module" src="/elm-land.js"></script>|__INLINE_JS__|' \
  "$TMP"
rm -f "$TMP.bak"

# Write up to CSS placeholder, then insert file contents, then remainder
awk -v css_file="$CSS" -v js_file="$JS" '
{
    if (index($0, "__INLINE_CSS__")) {
        sub("__INLINE_CSS__", "")
        print "<style>"
        while ((getline line < css_file) > 0) print line
        close(css_file)
        print "</style>"
    } else if (index($0, "__INLINE_JS__")) {
        sub("__INLINE_JS__", "")
        print "<script type=\"module\">"
        while ((getline line < js_file) > 0) print line
        close(js_file)
        print "</script>"
    } else {
        print
    }
}' "$TMP" > "$HTML"

rm "$TMP"

echo "✅ Inlined CSS and JS into $HTML"
