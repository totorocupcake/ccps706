console.log("app.js loaded successfully");
import "phoenix_html"
import {LiveSocket} from "phoenix_live_view"
import {Socket} from "phoenix"
import topbar from "../vendor/topbar"

// LiveView setup
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken}
});

// Progress bar configuration
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Connect LiveView - this is critical
liveSocket.connect()
window.liveSocket = liveSocket

// Chat functionality - only run this if user is logged in
window.addEventListener('DOMContentLoaded', () => {
  // Only initialize chat if we're on the chat page
  const chatArea = document.getElementById('chat-area');
  if (chatArea && window.userToken) {
    // Create socket with token
    const socket = new Socket('/socket', {
      params: {token: window.userToken}
    });
    
    // Debug callbacks
    socket.onOpen(() => console.log("Socket connected"));
    socket.onError((e) => console.error("Socket error:", e));
    
    // Connect
    socket.connect();
    
    // Create and join channel
    const channel = socket.channel('default:lobby', {});
    
    // Set up UI event handlers
    const messageInput = document.getElementById('message');
    const nameInput = document.getElementById('name');
    const messageList = document.getElementById('message-list');
    
    if (messageInput && nameInput) {
      messageInput.addEventListener('keypress', event => {
        if (event.keyCode === 13) {
          channel.push('new_message', {
            name: nameInput.value,
            message: messageInput.value
          });
          messageInput.value = '';
        }
      });
    }
    
    if (messageList) {
      channel.on('new_message', payload => {
        messageList.innerHTML += `<div><b>${payload.name || 'Anonymous'}:</b> ${payload.message}</div>`;
        messageList.scrollTop = messageList.scrollHeight;
      });
    }
    
    // Join the channel
    channel.join()
      .receive('ok', resp => console.log('Joined channel successfully', resp))
      .receive('error', resp => console.error('Unable to join channel', resp));
    
    // Make available globally for debugging
    window.socket = socket;
    window.channel = channel;
  }
});

// Debug form submission
window.addEventListener("DOMContentLoaded", function() {
  const form = document.getElementById("registration_form");
  if (form) {
    console.log("Registration form found");
    form.addEventListener("submit", function(e) {
      console.log("Form submitted");
      console.log(e);
    });
  }
});