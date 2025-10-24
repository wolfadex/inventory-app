acadia-to-elm:
    acadia make --generate-elm-endpoints=gen

css-dev:
    css-in-elm watch public/styles.css src/Css.elm

css-prod:
    css-in-elm build public/styles.css src/Css.elm

elm-dev:
    elm-watch hot

elm-prod:
    elm-watch make --optimize

elm-review-dev:
    elm-review --watch --fix

elm-review-prod:
    elm-review --watch --fix

dev-serve:
    acadia serve --html=public/index.html

build: acadia-to-elm css-prod  elm-review-prod elm-prod
    @echo "Built"

