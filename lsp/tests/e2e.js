#!/usr/bin/env node
// lsp/tests/e2e.js -- end-to-end test of the spf64 LSP server over stdio.
// run from D:\PRO\spf:   node lsp\tests\e2e.js
'use strict';
const { spawn } = require('child_process');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');           // D:\PRO\spf
const FIXTURE = path.join(__dirname, 'fixture');
const SPFX64 = 'D:\\PRO\\spf-x64';
const toUri = p => 'file:///' + p.replace(/\\/g, '/').replace(/:/, '%3A');

const srv = spawn(path.join(ROOT, 'spf64.exe'), ['lsp\\lsp-server.f'], { cwd: ROOT });
let outBuf = Buffer.alloc(0);
const pending = [];            // resolve callbacks for incoming messages
const messages = [];           // all parsed incoming messages

srv.stderr.on('data', d => process.stderr.write('[srv] ' + d));
srv.on('exit', c => { if (!done) { console.error('server exited early: ' + c); process.exit(1); } });

srv.stdout.on('data', d => {
  outBuf = Buffer.concat([outBuf, d]);
  for (;;) {
    const hdrEnd = outBuf.indexOf('\r\n\r\n');
    if (hdrEnd < 0) break;
    const m = /Content-Length:\s*(\d+)/i.exec(outBuf.slice(0, hdrEnd).toString());
    if (!m) { console.error('bad header'); process.exit(1); }
    const len = +m[1];
    if (outBuf.length < hdrEnd + 4 + len) break;
    const body = outBuf.slice(hdrEnd + 4, hdrEnd + 4 + len).toString('utf8');
    outBuf = outBuf.slice(hdrEnd + 4 + len);
    let msg;
    try { msg = JSON.parse(body); } catch (e) { console.error('bad json from server: ' + body); process.exit(1); }
    messages.push(msg);
    while (pending.length && pending[0](msg)) pending.shift();
  }
});

function send(obj) {
  const s = JSON.stringify(obj);
  srv.stdin.write('Content-Length: ' + Buffer.byteLength(s) + '\r\n\r\n' + s);
}
let nextId = 1;
function request(method, params) {
  const id = nextId++;
  send({ jsonrpc: '2.0', id, method, params });
  return new Promise(res => {
    pending.push(msg => { if (msg.id === id) { res(msg); return true; } return false; });
  });
}
function notify(method, params) { send({ jsonrpc: '2.0', method, params }); }
function waitFor(pred) {
  const hit = messages.find(pred);
  if (hit) return Promise.resolve(hit);
  return new Promise(res => {
    pending.push(msg => { if (pred(msg)) { res(msg); return true; } return false; });
  });
}

let fails = 0, done = false;
function check(cond, name, extra) {
  console.log((cond ? 'PASS ' : 'FAIL ') + name + (cond ? '' : ('   ' + (extra === undefined ? '' : JSON.stringify(extra)).slice(0, 400))));
  if (!cond) fails++;
}

const MAIN_TEXT = [
  '\\ demo',                                  // 0
  'REQUIRE FIXTURE-HELPER lib.f',             // 1
  ': MYWORD DUP * ;',                         // 2
  'DU',                                       // 3
  'FIXTURE-HELPER SHADOW-ONLY MYWORD',        // 4
  'EXIT',                                     // 5
  ''
].join('\n');
const mainUri = toUri(path.join(FIXTURE, 'main.f'));

(async () => {
  setTimeout(() => { console.error('TIMEOUT'); process.exit(1); }, 60000);

  const init = await request('initialize', {
    rootUri: toUri(FIXTURE),
    capabilities: {},
    initializationOptions: {
      spfx64Root: SPFX64,
      wdb: [SPFX64 + '\\src\\runtime\\spf64.exe.wdb', SPFX64 + '\\src\\seed\\seedw.wdb'],
      scanRoots: [FIXTURE],
    },
  });
  check(init.result && init.result.capabilities && init.result.capabilities.hoverProvider === true, 'initialize', init);
  check(init.result && init.result.serverInfo && init.result.serverInfo.name === 'spf64-lsp', 'serverInfo', init);

  notify('initialized', {});

  // didOpen -> diagnostics: only DU unknown (REQUIRE args skipped, SHADOW-ONLY indexed)
  notify('textDocument/didOpen', { textDocument: { uri: mainUri, languageId: 'spf-forth', version: 1, text: MAIN_TEXT } });
  const diag1 = await waitFor(m => m.method === 'textDocument/publishDiagnostics');
  check(diag1.params.uri === mainUri, 'diag-uri', diag1.params);
  const names = diag1.params.diagnostics.map(d => /unknown word: (\S+)/.exec(d.message)?.[1]).sort();
  check(JSON.stringify(names) === JSON.stringify(['DU']), 'diag-names', names);
  const du = diag1.params.diagnostics[0];
  check(du && du.range.start.line === 3 && du.range.start.character === 0 && du.range.end.character === 2, 'diag-range', du && du.range);

  // completion after "DU" (line 3, char 2)
  const comp = await request('textDocument/completion', { textDocument: { uri: mainUri }, position: { line: 3, character: 2 } });
  const items = comp.result && comp.result.items || [];
  check(items.some(i => i.label === 'DUP'), 'completion-dup', items.slice(0, 5));
  check(items.length > 0 && items.every(i => /^du/i.test(i.label)), 'completion-prefix-ci', items.map(i => i.label));

  // hover on DUP (line 2, char 10) -> kernel word, wdb source
  const hov = await request('textDocument/hover', { textDocument: { uri: mainUri }, position: { line: 2, character: 10 } });
  const hv = hov.result && hov.result.contents && hov.result.contents.value || '';
  check(hv.includes('**DUP**'), 'hover-dup', hv);
  check(hv.includes('prims.f'), 'hover-dup-wdb', hv);

  // hover on MYWORD (line 2, char 3) -> this file
  const hov2 = await request('textDocument/hover', { textDocument: { uri: mainUri }, position: { line: 2, character: 3 } });
  const hv2 = hov2.result && hov2.result.contents && hov2.result.contents.value || '';
  check(hv2.includes('**MYWORD**') && hv2.includes('this file'), 'hover-myword', hv2);
  check(hv2.includes(': MYWORD DUP * ;'), 'hover-myword-text', hv2);

  // hover on FIXTURE-HELPER (line 4) -> REQUIRE context, lib.f
  const hov3 = await request('textDocument/hover', { textDocument: { uri: mainUri }, position: { line: 4, character: 2 } });
  const hv3 = hov3.result && hov3.result.contents && hov3.result.contents.value || '';
  check(hv3.includes('**FIXTURE-HELPER**') && hv3.includes('lib.f'), 'hover-fixture', hv3);
  check(hv3.includes('REQUIRE/INCLUDE'), 'hover-fixture-ctx', hv3);

  // hover on EXIT (line 5) -> the KERNEL word, NOT shadow.f's redefinition
  const hovE = await request('textDocument/hover', { textDocument: { uri: mainUri }, position: { line: 5, character: 1 } });
  const hvE = hovE.result && hovE.result.contents && hovE.result.contents.value || '';
  check(hvE.includes('running spf64 image'), 'hover-exit-kernel', hvE);
  check(!hvE.includes('shadow.f'), 'hover-exit-not-shadow', hvE);

  // hover on SHADOW-ONLY (line 4) -> found, but marked as NOT loaded here
  const hovS = await request('textDocument/hover', { textDocument: { uri: mainUri }, position: { line: 4, character: 16 } });
  const hvS = hovS.result && hovS.result.contents && hovS.result.contents.value || '';
  check(hvS.includes('**SHADOW-ONLY**') && hvS.includes('not loaded in this file'), 'hover-notloaded', hvS);
  check(hvS.includes('shadow.f'), 'hover-notloaded-file', hvS);

  // definition of FIXTURE-HELPER -> lib.f (via the REQUIRE context)
  const def = await request('textDocument/definition', { textDocument: { uri: mainUri }, position: { line: 4, character: 2 } });
  check(def.result && /fixture\/lib\.f$/i.test(def.result.uri) && def.result.range.start.line === 1, 'definition-ws', def.result);

  // definition of MYWORD -> same file
  const def2 = await request('textDocument/definition', { textDocument: { uri: mainUri }, position: { line: 4, character: 28 } });
  check(def2.result && def2.result.uri === mainUri && def2.result.range.start.line === 2, 'definition-doc', def2.result);

  // definition of DUP -> spf-x64 seed source
  const def3 = await request('textDocument/definition', { textDocument: { uri: mainUri }, position: { line: 2, character: 10 } });
  check(def3.result && /prims\.f$/i.test(def3.result.uri || ''), 'definition-wdb', def3.result);

  // definition of EXIT -> never shadow.f (kernel word; wdb source or null)
  const defE = await request('textDocument/definition', { textDocument: { uri: mainUri }, position: { line: 5, character: 1 } });
  check(!(defE.result && /shadow\.f/i.test(defE.result.uri || '')), 'definition-exit-not-shadow', defE.result);

  // definition of SHADOW-ONLY -> shadow.f as the last resort
  const defS = await request('textDocument/definition', { textDocument: { uri: mainUri }, position: { line: 4, character: 16 } });
  check(defS.result && /shadow\.f$/i.test(defS.result.uri || ''), 'definition-notloaded', defS.result);

  // documentSymbol
  const sym = await request('textDocument/documentSymbol', { textDocument: { uri: mainUri } });
  check(Array.isArray(sym.result) && sym.result.some(s => s.name === 'MYWORD' && s.kind === 12), 'symbols', sym.result);

  // didChange: fix DU -> DUP: diagnostics become empty
  notify('textDocument/didChange', {
    textDocument: { uri: mainUri, version: 2 },
    contentChanges: [{ text: MAIN_TEXT.replace('\nDU\n', '\nDUP\n') }],
  });
  const diag2 = await waitFor(m => m.method === 'textDocument/publishDiagnostics' && m !== diag1);
  check(diag2.params.diagnostics.length === 0, 'rediag', diag2.params.diagnostics);

  // didClose -> empty diagnostics
  notify('textDocument/didClose', { textDocument: { uri: mainUri } });
  const diag3 = await waitFor(m => m.method === 'textDocument/publishDiagnostics' && m !== diag1 && m !== diag2);
  check(diag3.params.diagnostics.length === 0, 'close-clears', diag3.params);

  // unknown request -> error
  const bad = await request('no/such', {});
  check(bad.error && bad.error.code === -32601, 'unknown-method', bad);

  const sd = await request('shutdown');
  check(sd.result === null, 'shutdown', sd);
  done = true;
  notify('exit');
  await new Promise(res => srv.on('exit', res));

  console.log(fails === 0 ? 'ALL PASS' : ('FAILURES: ' + fails));
  process.exit(fails === 0 ? 0 : 1);
})().catch(e => { console.error(e); process.exit(1); });
