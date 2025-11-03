import { Buffer } from "node:buffer";
import http from "node:http";
import "./XMLHttpRequest-poly.js";

import { Elm } from "./elm-server.js";

const port = process.env.PORT || 8000;

http
  .createServer(async (req, res) => {
    try {
      const body = await getBody(req);
      const elmRequest = {
        path: req.url,
        body: body || "",
        method: req.method,
        headers: Object.entries(req.headers),
      };

      const handler = Elm.Server.init({
        flags: elmRequest,
      });

      handler.ports.respond.subscribe(function (response) {
        const headers = {};

        for (const header of response.headers) {
          headers[header[0]] = header[1];
        }
        res.writeHead(response.status, headers);

        const respBody = Buffer.from(response.body, "base64");

        res.write(respBody);
        res.end();

        handler.ports.respond.unsubscribe();
      });
    } catch (error) {
      console.error(error);
      res.writeHead(500);
      res.write("Server error");
      res.end();
    }
  })
  .listen(port, () => {
    console.log(`App is running on port ${port}`);
  });

function getBody(request) {
  let body;
  return new Promise(function (resolve) {
    request.on("data", (chunk) => {
      if (body == null) {
        body = chunk;
      } else {
        body = Buffer.concat(body, chunk);
      }
    });
    request.on("end", () => {
      if (body == null) {
        resolve("");
      } else {
        resolve(body.toString("base64"));
      }
    });
  });
}
