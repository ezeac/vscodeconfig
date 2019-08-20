import * as ts from 'typescript';
import { AST } from 'vue-eslint-parser';
import { T_TypeScript } from '../dependencyService';
export declare const renderHelperName = "__vlsRenderHelper";
export declare const componentHelperName = "__vlsComponentHelper";
export declare const iterationHelperName = "__vlsIterationHelper";
export declare function getTemplateTransformFunctions(ts: T_TypeScript): {
    transformTemplate: (program: AST.ESLintProgram, code: string) => ts.Expression[];
    injectThis: (exp: ts.Expression, scope: string[], start: number) => ts.Expression;
};
