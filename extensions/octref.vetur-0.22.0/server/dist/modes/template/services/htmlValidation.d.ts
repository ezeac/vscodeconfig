import { CLIEngine } from 'eslint';
import { TextDocument, Diagnostic } from 'vscode-languageserver-types';
export declare function doESLintValidation(document: TextDocument, engine: CLIEngine): Diagnostic[];
export declare function createLintEngine(): CLIEngine;
