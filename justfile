dev:
    npm run dev

publish-acadia:
    ./acadia_build.sh

    # Preview your app at `acadia.build`
    acadia preview gen/index.html
