import "./style.css";
import "./picocss/pico.min.css";
import ElmLand from "../.elm-land/package/src/client";
import Main from "../src/Main.elm";

// 1. Define Elm flags
let flags = {};

// 2. Start the Elm application
let app: Elm.App<Ports> = ElmLand.init({
  root: Main,
  flags,
});

// 3. Handle ports
type Ports = {
  reportUnexpectedFlags: Elm.OutgoingPort<{ error: string }>;
};

app.ports?.reportUnexpectedFlags.subscribe?.(({ error }) => {
  console.error(`FLAGS\n`, error);
});
