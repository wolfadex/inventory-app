# Inventory App

An app for Bekah

## Development

### Dependencies

I use [mise](https://mise.jdx.dev/) for dependency management. If you want to do things yourself you can install everything maually.

**Core**

- [Elm](https://elm-lang.org/) - for the frontend
- [Acadia](https://acadia.engineering/) - for the backend
- [Node](https://nodejs.org/en)
    - [@ryannhg/css-in-elm](https://www.npmjs.com/package/@ryannhg/css-in-elm) - helper for CSS and Elm

**Tooling**

- [just](https://just.systems/) - for running commands
- [elm-watch](https://lydell.github.io/elm-watch/) - hot reloading for Elm
- [elm-format](https://github.com/avh4/elm-format)
- [elm-review](https://www.npmjs.com/package/elm-review)


### Building for dev

I run each of these in their own terminal tab.

- `just acadia-to-elm` - generate Elm bindings from Acadia code
- `just css-dev` - generate Elm code from CSS
- `just elm-dev` - start the Elm hot reload server
- `just dev-serve` - start the dev server

Run this as needed

- `just elm-review-dev`

### Building for prod

- `just build`
