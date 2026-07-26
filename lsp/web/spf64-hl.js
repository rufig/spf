// spf64-hl.js -- browser syntax highlighting for SP-Forth, driven by the REAL
// dictionary of the spf64 WASM build (spf-min.wasm, assembled by spf64 itself).
//
// On init the wasm Forth boots and executes a small Forth driver that walks
// _VOC-LIST and prints every word ("!" prefix = immediate, "~" = normal).
// The highlighter then colors tokens by what THIS Forth actually knows:
// immediate words (control flow) vs ordinary dictionary words vs unknowns.
// Comments, strings, numbers, defining words and { locals } are recognized
// by the same surface rules the spf64 LSP server uses.
//
// Usage:
//   <script src="spf64-hl.js" data-wasm="spf-min.wasm"></script>
//   ... <pre class="forth"> DUP SWAP ... </pre>
// or manually:  spf64hl.init({wasm:'spf-min.wasm'}).then(() => spf64hl.highlightAll())
//
// Needs cross-origin isolation (COOP/COEP headers) because spf-min.wasm
// imports a shared memory; without it the highlighter falls back to a
// built-in word list (syntax only, no live dictionary).
'use strict';

(function () {
  const DRIVER = [
    ': HL-WL @ BEGIN DUP WHILE DUP 8 + C@ 128 AND IF 33 EMIT ELSE 126 EMIT THEN DUP NAME>STRING TYPE 10 EMIT @ REPEAT DROP ;',
    ': HL-DUMP _VOC-LIST @ BEGIN DUP WHILE DUP CELL+ HL-WL @ REPEAT DROP ;',
    'HL-DUMP BYE',
    '',
  ].join('\n');

  const DEFINERS = new Set([
    ':', 'CODE', 'M:', 'T:', ':T', 'VARIABLE', '2VARIABLE', 'CONSTANT', '2CONSTANT',
    'VALUE', '2VALUE', 'DEFER', 'VECT', 'USER', 'USER-CREATE', 'USER-VALUE',
    'CREATE', 'CREATED', 'VOCABULARY', 'MODULE:', 'WINAPI:', 'WINAPI64:', 'WINAPI64P:', 'DLFN:',
  ]);
  // fallback control words when the wasm dictionary is unavailable
  const FALLBACK_IMM = new Set([
    'IF', 'ELSE', 'THEN', 'BEGIN', 'WHILE', 'REPEAT', 'UNTIL', 'AGAIN', 'DO', '?DO',
    'LOOP', '+LOOP', 'LEAVE', 'CASE', 'OF', 'ENDOF', 'ENDCASE', 'RECURSE', 'DOES>',
    ';', '[', ']', "[']", '[CHAR]', 'POSTPONE', 'S"', '."', 'ABORT"', 'C"', '{',
  ]);

  const dict = new Map();       // word -> {imm:bool}
  let ready = false, liveDict = false;

  function isNumber(tok) {
    return /^[-+]?[0-9]+\.?$/.test(tok) || /^0[xX][0-9A-Fa-f]+$/.test(tok) || /^'.'$/.test(tok);
  }

  // spf-min.wasm imports a SHARED memory (for real threads).  Without
  // cross-origin isolation (file://, plain http) SharedArrayBuffer does not
  // exist -- so flip the import's limits flag to non-shared in the module
  // bytes.  The highlighter stubs thread_spawn anyway, and the kernel's only
  // atomics are cmpxchg/store, which are valid on non-shared memory too.
  function unshareMemory(bytes) {
    const u = new Uint8Array(bytes.slice(0));
    const pat = [0x03, 0x65, 0x6E, 0x76, 0x06, 0x6D, 0x65, 0x6D, 0x6F, 0x72, 0x79, 0x02]; // \3env\6memory\2
    for (let i = 0; i + pat.length < u.length; i++) {
      let hit = true;
      for (let k = 0; k < pat.length; k++) if (u[i + k] !== pat[k]) { hit = false; break; }
      if (hit) {
        const f = i + pat.length;
        if (u[f] === 0x03) u[f] = 0x01;       // shared min+max -> min+max
        else if (u[f] === 0x02) u[f] = 0x00;  // shared min -> min
        return u.buffer;
      }
    }
    return u.buffer;
  }

  function wasmBytes(wasmUrl) {
    if (window.SPF64_WASM_B64) {              // embedded (works from file://)
      const s = atob(window.SPF64_WASM_B64);
      const u = new Uint8Array(s.length);
      for (let i = 0; i < s.length; i++) u[i] = s.charCodeAt(i);
      return Promise.resolve(u.buffer);
    }
    return fetch(wasmUrl).then(r => r.arrayBuffer());
  }

  async function init(opts) {
    opts = opts || {};
    const wasmUrl = opts.wasm || 'spf-min.wasm';
    try {
      let bytes = await wasmBytes(wasmUrl);
      const isolated = typeof SharedArrayBuffer !== 'undefined' &&
        (typeof crossOriginIsolated === 'undefined' || crossOriginIsolated);
      if (!isolated) bytes = unshareMemory(bytes);
      const mod = await WebAssembly.compile(bytes);
      const memory = isolated
        ? new WebAssembly.Memory({ initial: 48, maximum: 512, shared: true })
        : new WebAssembly.Memory({ initial: 48, maximum: 512 });
      const dv = () => new DataView(memory.buffer);
      const u8 = () => new Uint8Array(memory.buffer);
      let out = '';
      const stdin = new TextEncoder().encode(DRIVER);
      let stdinPos = 0;
      const argv = ['spf-min.wasm'];
      const imports = {
        env: {
          memory,
          thread_spawn: () => -1,
          host_load: () => 0,
          sock_op: () => -1,
        },
        wasi_snapshot_preview1: {
          fd_write(fd, iovs, n, nw) {
            const d = dv(); let total = 0;
            for (let i = 0; i < n; i++) {
              const p = d.getUint32(iovs + i * 8, true), l = d.getUint32(iovs + i * 8 + 4, true);
              out += new TextDecoder().decode(u8().slice(p, p + l));
              total += l;
            }
            d.setUint32(nw, total, true); return 0;
          },
          fd_read(fd, iovs, n, nr) {
            const d = dv(), mem = u8(); let total = 0;
            for (let i = 0; i < n; i++) {
              const p = d.getUint32(iovs + i * 8, true), l = d.getUint32(iovs + i * 8 + 4, true);
              const take = Math.min(l, stdin.length - stdinPos);
              for (let k = 0; k < take; k++) mem[p + k] = stdin[stdinPos + k];
              stdinPos += take; total += take;
            }
            d.setUint32(nr, total, true); return 0;
          },
          args_sizes_get(argcPtr, bufszPtr) {
            const d = dv();
            d.setUint32(argcPtr, argv.length, true);
            let sz = 0; for (const a of argv) sz += a.length + 1;
            d.setUint32(bufszPtr, sz, true); return 0;
          },
          args_get(ptrsPtr, bufPtr) {
            const d = dv(), mem = u8(); let sp = bufPtr;
            for (let i = 0; i < argv.length; i++) {
              d.setUint32(ptrsPtr + i * 4, sp, true);
              for (const c of argv[i]) mem[sp++] = c.charCodeAt(0);
              mem[sp++] = 0;
            }
            return 0;
          },
        },
      };
      const inst = await WebAssembly.instantiate(mod, imports);
      inst.exports.init();
      inst.exports._start();
      for (const line of out.split('\n')) {
        const m = /^([!~])(\S+)$/.exec(line.trim());
        if (m) dict.set(m[2], { imm: m[1] === '!' });
      }
      liveDict = dict.size > 0;
      console.info('spf64-hl: live wasm dictionary, ' + dict.size + ' words');
    } catch (e) {
      console.warn('spf64-hl: wasm dictionary unavailable (' + e.message + '), syntax-only fallback');
      liveDict = false;
    }
    ready = true;
  }

  function classify(tok, inDict, imm) {
    if (isNumber(tok)) return 'num';
    if (DEFINERS.has(tok)) return 'definer';
    if (liveDict ? imm : FALLBACK_IMM.has(tok)) return 'imm';
    if (inDict) return 'word';
    return 'unk';
  }

  // tokenizer: the LSP server's WALK-F surface rules, producing HTML
  function highlightText(text) {
    const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    const span = (cls, s) => '<span class="spfhl-' + cls + '">' + esc(s) + '</span>';
    let html = '', i = 0, pendingDef = false, brace = false, dash = false, skipn = 0;
    const docDefs = new Set();            // words defined by this very fragment
    const locals = new Set();             // { } names, scoped to the current definition
    const n = text.length;
    while (i < n) {
      // whitespace
      let j = i;
      while (j < n && /\s/.test(text[j])) j++;
      if (j > i) { html += esc(text.slice(i, j)); i = j; }
      if (i >= n) break;
      // token
      j = i;
      while (j < n && !/\s/.test(text[j])) j++;
      const tok = text.slice(i, j);
      const entry = dict.get(tok);
      // inside { ... }: `\` is the locals separator, `--` starts the comment tail
      if (brace) {
        let cls = dash ? 'cmt' : 'param';
        if (tok === '}') { brace = false; cls = 'imm'; }
        else if (tok === '--') { dash = true; cls = 'cmt'; }
        else if (tok === '\\') cls = 'cmt';
        else if (!dash) locals.add(tok);
        html += span(cls, tok);
        i = j; continue;
      }
      // comments
      if (tok === '\\' || tok === '\\EOF') {
        let e = text.indexOf('\n', i);
        if (e < 0 || tok === '\\EOF') e = n;
        html += span('cmt', text.slice(i, e));
        i = e; continue;
      }
      if (tok === '(' || tok === '.(') {
        let e = text.indexOf(')', i);
        e = e < 0 ? n : e + 1;
        html += span('cmt', text.slice(i, e));
        i = e; continue;
      }
      // strings: any word ending in a quote parses to the next quote
      if (tok.endsWith('"')) {
        let e = text.indexOf('"', j);
        let eol = text.indexOf('\n', j);
        if (eol < 0) eol = n;
        e = (e < 0 || e > eol) ? eol : e + 1;
        html += span('definer', tok) + span('str', text.slice(j, e));
        i = e; pendingDef = false; continue;
      }
      let cls;
      if (skipn > 0) { skipn--; cls = 'arg'; }
      else if (pendingDef) { cls = 'def'; pendingDef = false; docDefs.add(tok); }
      else if (tok === '{') { brace = true; dash = false; cls = 'imm'; }
      else if (tok === 'REQUIRE') { skipn = 2; cls = 'definer'; }
      else if (tok === '[DEFINED]' || tok === '[UNDEFINED]' || tok === 'CHAR' || tok === '[CHAR]') { skipn = 1; cls = 'imm'; }
      else if (locals.has(tok)) cls = 'param';
      else {
        if (DEFINERS.has(tok)) pendingDef = true;
        if (tok === ';') locals.clear();
        cls = classify(tok, !!entry || docDefs.has(tok), entry && entry.imm);
      }
      html += span(cls, tok);
      i = j;
    }
    return html;
  }

  const CSS = `
.spfhl-cmt { color: #6a9955; font-style: italic; }
.spfhl-str { color: #ce9178; }
.spfhl-num { color: #b5cea8; }
.spfhl-imm { color: #c586c0; font-weight: 600; }
.spfhl-definer { color: #569cd6; font-weight: 600; }
.spfhl-def { color: #dcdcaa; font-weight: 700; }
.spfhl-word { color: #9cdcfe; }
.spfhl-param { color: #4ec9b0; font-style: italic; }
.spfhl-arg { color: #d7ba7d; }
.spfhl-unk { color: inherit; border-bottom: 1px dotted #d16969; }
@media (prefers-color-scheme: light) {
  .spfhl-cmt { color: #008000; }
  .spfhl-str { color: #a31515; }
  .spfhl-num { color: #098658; }
  .spfhl-imm { color: #af00db; }
  .spfhl-definer { color: #0000ff; }
  .spfhl-def { color: #795e26; }
  .spfhl-word { color: #001080; }
  .spfhl-param { color: #267f99; }
  .spfhl-arg { color: #986801; }
  .spfhl-unk { border-bottom-color: #cd3131; }
}
pre.forth, code.language-forth { font-family: Consolas, 'Cascadia Mono', monospace; }
`;

  function injectCss() {
    if (document.getElementById('spf64-hl-css')) return;
    const st = document.createElement('style');
    st.id = 'spf64-hl-css';
    st.textContent = CSS;
    document.head.appendChild(st);
  }

  function highlight(el) {
    injectCss();
    el.innerHTML = highlightText(el.textContent);
    el.setAttribute('data-spfhl', liveDict ? 'live' : 'fallback');
  }

  function highlightAll(root) {
    (root || document).querySelectorAll('pre.forth, code.language-forth').forEach(highlight);
  }

  window.spf64hl = { init, highlight, highlightAll, classify, dict, get ready() { return ready; }, get live() { return liveDict; } };

  const script = document.currentScript;
  if (script && script.dataset.wasm !== undefined) {
    const run = () => init({ wasm: script.dataset.wasm || 'spf-min.wasm' }).then(() => highlightAll());
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', run);
    else run();
  }
})();
