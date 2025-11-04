dev:
    run-pty run-pty.json

acadia-serve:
    nodemon -w src/Backend.db --exec "acadia serve"

acadia-build:
    acadia make --generate-elm-endpoints=gen

server-build-dev:
    nodemon -w src/Server.elm --exec "elm-esm make src/Server.elm --output=./elm-server.js"

server-serve:
    node --watch server.js

publish-acadia:
    ./acadia_build.sh

    # Preview your app at `acadia.build`
    acadia preview gen/index.html

build: acadia-build
    tsc
    vite build