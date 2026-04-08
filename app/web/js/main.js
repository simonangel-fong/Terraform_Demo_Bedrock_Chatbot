/* ============================================================
   main.js — Lumen Chatbot
   ============================================================

   Chat history data structure
   ----------------------------
   chatHistory is an array of Bedrock-style message objects sent
   with every request so the bot has full conversational context.

   Each entry:
   {
     role: "user" | "assistant",
     content: [
       {
         text: string
       }
     ]
   }

   On every send, the payload to chatbot_url is:
   {
     prompt: string,          // the user's current input
     history: chatHistory[]   // all prior turns, oldest first
   }

   The current user prompt is NOT pushed into history until the
   request succeeds. The backend appends prompt to history before
   calling the model.
   ============================================================ */

const API_URL = 'https://chatbot.arguswatcher.net/demo/chatbot';

// ── State ──────────────────────────────────────────────────
let chatHistory = []; // { role, content: [{ text }] }[]
let isLoading = false;
let sidebarOpen = true;

// ── DOM refs ───────────────────────────────────────────────
const sidebar = document.getElementById('sidebar');
const openSidebarBtn = document.getElementById('open-sidebar-btn');
const closeSidebarBtn = document.getElementById('close-sidebar-btn');
const chatEl = document.getElementById('chat');
const welcomeEl = document.getElementById('welcome');
const messagesEl = document.getElementById('messages');
const inputEl = document.getElementById('input');
const sendBtn = document.getElementById('send-btn');

// ── Sidebar ────────────────────────────────────────────────
function openSidebar() {
  sidebarOpen = true;
  sidebar.style.width = '';
  sidebar.style.borderRightWidth = '';
  openSidebarBtn.classList.add('hidden');
}

function closeSidebar() {
  sidebarOpen = false;
  sidebar.style.width = '0px';
  sidebar.style.borderRightWidth = '0px';
  openSidebarBtn.classList.remove('hidden');
}

openSidebarBtn.addEventListener('click', openSidebar);
closeSidebarBtn.addEventListener('click', closeSidebar);

// ── Input helpers ──────────────────────────────────────────
function autoResize(el) {
  el.style.height = 'auto';
  el.style.height = Math.min(el.scrollHeight, 144) + 'px';
}

inputEl.addEventListener('input', () => autoResize(inputEl));

inputEl.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
});

sendBtn.addEventListener('click', sendMessage);

// ── Set loading state ──────────────────────────────────────
function setLoading(loading) {
  isLoading = loading;
  sendBtn.disabled = loading;
  inputEl.disabled = loading;
}

// ── Scroll ─────────────────────────────────────────────────
function scrollToBottom() {
  chatEl.scrollTop = chatEl.scrollHeight;
}

// ── HTML escape ────────────────────────────────────────────
function escapeHtml(str) {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br/>');
}

// ── Build Bedrock-style message ────────────────────────────
function buildMessage(role, text) {
  return {
    role,
    content: [
      {
        text
      }
    ]
  };
}

// ── Render a user bubble ───────────────────────────────────
function renderUserMessage(text) {
  const row = document.createElement('div');
  row.className = 'flex justify-end msg-appear';
  row.innerHTML = `
    <div class="max-w-[72%]">
      <div class="bg-bg-raised border border-bg-border rounded-2xl rounded-tr-sm px-4 py-2.5 text-sm text-text-primary leading-relaxed">
        ${escapeHtml(text)}
      </div>
    </div>`;
  messagesEl.appendChild(row);
  scrollToBottom();
}

// ── Render a bot bubble (returns the content element) ─────
function renderBotShell() {
  const id = 'bot-' + Date.now();
  const row = document.createElement('div');
  row.className = 'flex justify-start msg-appear';
  row.innerHTML = `
    <div class="flex items-start gap-3 max-w-[80%]">
      <div class="w-6 h-6 mt-0.5 rounded-full bg-accent-dim border border-accent/20 flex items-center justify-center shrink-0">
        <svg width="10" height="10" viewBox="0 0 10 10" fill="none">
          <circle cx="5" cy="5" r="3" stroke="#c8a96e" stroke-width="1"/>
          <circle cx="5" cy="5" r="1" fill="#c8a96e"/>
        </svg>
      </div>
      <div
        id="${id}"
        class="bg-bg-surface border border-bg-border rounded-2xl rounded-tl-sm px-4 py-2.5 text-sm text-text-primary leading-relaxed cursor-blink"
      ></div>
    </div>`;
  messagesEl.appendChild(row);
  scrollToBottom();
  return document.getElementById(id);
}

// ── Typewriter effect ──────────────────────────────────────
function typewrite(el, text, onDone) {
  let i = 0;
  function step() {
    if (i < text.length) {
      el.textContent += text[i++];
      scrollToBottom();
      setTimeout(step, 16 + Math.random() * 12);
    } else {
      el.classList.remove('cursor-blink');
      if (onDone) onDone();
    }
  }
  step();
}

// ── Core: send message ─────────────────────────────────────
async function sendMessage() {
  const text = inputEl.value.trim();
  if (!text || isLoading) return;

  // Hide welcome screen on first message
  welcomeEl.style.display = 'none';

  // Snapshot history before this turn
  const historySnapshot = [...chatHistory];

  // Clear input early for better UX
  inputEl.value = '';
  inputEl.style.height = 'auto';

  // Render user bubble immediately
  renderUserMessage(text);

  // Render bot shell with blinking cursor
  const botBubble = renderBotShell();

  setLoading(true);

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        prompt: text,
        history: historySnapshot
      }),
    });

    if (!response.ok) {
      throw new Error(`Server responded with ${response.status}`);
    }

    const data = await response.json();
    const reply = (data.reply ?? data.message ?? data.response ?? '').trim();

    if (!reply) {
      throw new Error('Empty response from server');
    }

    // Only persist this round after success
    chatHistory.push(buildMessage('user', text));
    chatHistory.push(buildMessage('assistant', reply));

    // Typewrite the reply
    typewrite(botBubble, reply, () => setLoading(false));

  } catch (err) {
    const errorText = `Could not reach the server. ${err.message}`;
    botBubble.classList.remove('cursor-blink');
    botBubble.classList.add('bubble-error');
    botBubble.textContent = errorText;

    setLoading(false);
    console.error('[Lumen]', err);
  }
}