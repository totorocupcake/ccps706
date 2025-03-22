import {Socket} from "phoenix"

// Create a new socket
let socket = new Socket('/socket', { params: { token: window.userToken } });
socket.connect();

// Get access to the default channel
let channel = socket.channel('default:lobby', {});

// Wait until the DOM is fully loaded
document.addEventListener('DOMContentLoaded', () => {
  // Get DOM elements (using standard DOM API instead of jQuery)
  let list = document.getElementById('message-list');
  let message = document.getElementById('message');
  let name = document.getElementById('name');

  // Add event listener for message input
  message.addEventListener('keypress', event => {
    if (event.keyCode == 13) {
      channel.push('new_message', {name: name.value, message: message.value});
      message.value = '';
    }
  });

  // Listen for new messages from the channel
  channel.on('new_message', payload => {
    list.innerHTML += `<b>${payload.name || 'Anonymous'}:</b> ${payload.message}<br>`;
    list.scrollTop = list.scrollHeight;
  });
});

// Join the channel
channel
  .join()
  .receive('ok', resp => {
    console.log('Joined successfully', resp);
  })
  .receive('error', resp => {
    console.log('Unable to join', resp);
  });

export default socket;