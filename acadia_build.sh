#!/bin/bash

# Check if acadia is available
if ! command -v acadia &> /dev/null; then
  echo "acadia could not be found. Please ensure it is installed and in your PATH."
  exit 1
fi

#####
# 1. Generate Acadia modules
#####
echo "Compiling Acadia..."
acadia make

#####
# 2. Compile Elm application
#####
echo "Compiling Elm..."
elm make src/Main.elm --optimize --output=public/app.elm.js

#####
## 3. Generate an "index.html" file
#####
echo "Generating index.html file"
# Ensure the public folder exists
if [ ! -d "public" ]; then
  echo "The public directory does not exist."
  exit 1
fi

# Create or clear the index.html file
echo "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
<title>My Acadia App</title>" > gen/index.html

# Embed CSS files
for css_file in public/*.css; do
  if [ -e "$css_file" ]; then
    echo "<style>" >> gen/index.html
    cat "$css_file" >> gen/index.html
    echo "</style>" >> gen/index.html
  fi
done

echo "</head>
<body><div id=\"app\"></div>" >> gen/index.html

# Embed JS files
for js_file in public/*.js; do
  if [ -e "$js_file" ]; then
    echo "<script>" >> gen/index.html
    cat "$js_file" >> gen/index.html
    echo "</script>" >> gen/index.html
  fi
done

echo "</body>
</html>" >> gen/index.html

echo "gen/index.html has been created with embedded CSS and JS files."