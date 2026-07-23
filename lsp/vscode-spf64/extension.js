// spf64 VS Code extension: a thin LanguageClient over the spf64 LSP server
// (lsp/lsp-server.f running on spf64.exe itself).
'use strict';
const path = require('path');
const { workspace, window } = require('vscode');
const { LanguageClient } = require('vscode-languageclient/node');

let client;

exports.activate = function activate() {
  const cfg = workspace.getConfiguration('spf64');
  const serverPath = cfg.get('serverPath');
  const serverScript = cfg.get('serverScript');
  // CWD = the directory that CONTAINS lsp/ so the server's `REQUIRE lsp/...` resolves
  const cwd = path.dirname(path.dirname(serverScript));

  client = new LanguageClient(
    'spf64-lsp',
    'spf64 LSP',
    {
      command: serverPath,
      args: [serverScript],
      options: { cwd },
    },
    {
      documentSelector: [{ language: 'spf-forth' }],
      initializationOptions: {
        spfx64Root: cfg.get('spfx64Root') || undefined,
        wdb: cfg.get('wdb') || [],
        scanRoots: cfg.get('scanRoots') || [],
      },
    }
  );
  client.start().catch((e) => {
    window.showErrorMessage('spf64 LSP failed to start: ' + e.message +
      ' (check spf64.serverPath / spf64.serverScript settings)');
  });
};

exports.deactivate = function deactivate() {
  return client ? client.stop() : undefined;
};
