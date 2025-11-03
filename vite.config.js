import { defineConfig } from "vite";
import elm from "vite-plugin-elm-watch";
import elmLand from "./.elm-land/package/src/plugin";

export default defineConfig({
  server: {
    proxy: {
      "/_endpoints": "http://localhost:9000",
      "/api": "http://localhost:8000",
    },
  },
  plugins: [
    elm({
      mode: "debug",
    }),
    elmLand({
      router: "file-based",
      output: "spa",
    }),
  ],
});
