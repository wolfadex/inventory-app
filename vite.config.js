import { defineConfig } from "vite";
import elm from "vite-plugin-elm-watch";
import elmLand from "elm-land/vite";

export default defineConfig({
  server: {
    proxy: {
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
