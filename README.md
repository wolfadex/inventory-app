# Inventory App

An app for Bekah

## Development

### Dependencies


I use [mise](https://mise.jdx.dev/) for dependency management. If you want to do things yourself you can install everything maually.

- [Elm](https://elm-lang.org/) - for the frontend & server
- [Acadia](https://acadia.engineering/) - for the database
- [Node](https://nodejs.org/en) - for additional tooling
    - [@ryannhg/css-in-elm](https://www.npmjs.com/package/@ryannhg/css-in-elm) - helper for CSS and Elm
    - [elm-format](https://github.com/avh4/elm-format)
    - [elm-review](https://www.npmjs.com/package/elm-review)
    - [elm-esm]() - for building the server
    - [run-pty]() - runs all the tooling in parallel with a nice UI


### Building for dev

- `just dev` - start various dev servers in watch mode

### Building for prod

- `just build` - I haven't tested this yet

### Notes

Colors:

- #5C4B51
- #8CBEB2
- #F2EBBF
- #F3B562
- #F06060
