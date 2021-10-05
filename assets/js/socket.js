import {Socket} from "phoenix";

const socket = new Socket("/socket", {});
const authSocket = new Socket("/auth_socket", {
  params: {token: window.authToken}
});
const statsSocket = new Socket("/stats_socket", {});

socket.connect();
authSocket.onOpen(() => console.log('authSocket connected'));
authSocket.connect();
statsSocket.connect();

// We invoke socket.channel once per topic we want to connect to.
const pingChannel = socket.channel("ping");
const recurringChannel = authSocket.channel("recurring");
const dupeChannel = socket.channel("dupe");
const statsChannelInvalid = statsSocket.channel("invalid");
const statsChannelValid = statsSocket.channel("valid");

recurringChannel.on("new_token", (payload) => {
  console.log("received new auth token", payload);
});

dupeChannel.on("number", (payload) => {
  console.log("new number received", payload);
});

recurringChannel.join();
dupeChannel.join();

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

pingChannel.on("send_ping", (payload) => {
  console.log("ping requested", payload);
  pingChannel.push("ping")
    .receive("ok", (resp) => console.log("ping:", resp.ping));
});

statsChannelInvalid.join()
  .receive("error", () => statsChannelInvalid.leave());

statsChannelValid.join();

for (let i = 0; i < 5; i++) {
  statsChannelValid.push("ping");
}

export default socket;
