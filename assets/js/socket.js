import {Socket} from "phoenix";

const socket = new Socket("/socket", {});

socket.connect();

// We invoke socket.channel once per topic we want to connect to.
const pingChannel = socket.channel("ping");

pingChannel.join()
  .receive("ok", (resp) => {
    console.log("Joined ping", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join ping", resp);
  });

console.log("send ping");
pingChannel.push("ping")
  .receive("ok", (resp) => {
    console.log("receive", resp.ping);
  });

console.log("send pong");
pingChannel.push("pong")
  .receive("ok", (resp) => {
    console.log("won't happen");
  })
  .receive("error", (resp) => {
    console.error("won't happen yet");
  })
  .receive("timeout", (resp) => {
    console.error("pong message timeout", resp);
  });

pingChannel.push("param_ping", {error: true})
  .receive("error", (resp) => {
    console.error("param_ping error:", resp);
  });

pingChannel.push("param_ping", {error: false, arr: [1, 2]})
  .receive("ok", (resp) => {
    console.log("param_ping ok:", resp);
  });

export default socket;
