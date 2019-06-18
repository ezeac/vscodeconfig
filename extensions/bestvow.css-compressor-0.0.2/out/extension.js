'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const CleanCSS = require('clean-css');
let options = vscode.workspace.getConfiguration('CleanCSS').get("options");
function activate(context) {
    let disposable = vscode.commands.registerCommand('extension.CleanCSS', () => new Clean().formate());
    context.subscriptions.push(disposable);
}
exports.activate = activate;
class Clean {
    formate() {
        let editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        let doc = editor.document;
        if (doc.languageId === "css") {
            editor.edit(edit => {
                edit.replace(new vscode.Range(new vscode.Position(0, 0), new vscode.Position(doc.lineCount - 1, doc.lineAt(doc.lineCount - 1).text.length)), new CleanCSS(options).minify(doc.getText()).styles);
            });
        }
        else {
            return;
        }
    }
}
//# sourceMappingURL=extension.js.map