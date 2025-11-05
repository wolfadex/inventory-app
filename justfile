# Development

dev:
    run-pty run-pty.json

acadia-serve:
    nodemon -w src/Backend.db --exec "acadia make --generate-elm-endpoints=gen && acadia serve"

acadia-build:
    acadia make --generate-elm-endpoints=gen

css-dev:
    css-in-elm watch assets/style.css src/Css.elm

css-build:
    css-in-elm build assets/style.css src/Css.elm

server-build-dev:
    nodemon -w src/Server.elm --exec "elm-esm make src/Server.elm --output=./elm-server.js"

server-serve:
    node --watch server.js

elm-review-dev:
    elm-review --watch --fix

# Production

publish-acadia:
    ./acadia_build.sh

    # Preview your app at `acadia.build`
    acadia preview gen/index.html

elm-review-build:
    elm-review

build: elm-review-build acadia-build css-build
    tsc
    vite build