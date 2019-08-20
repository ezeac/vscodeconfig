"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const preprocess_1 = require("./preprocess");
const util_1 = require("./util");
function getVueSys(tsModule) {
    /**
     * This part is only accessed by TS module resolution
     */
    const vueSys = Object.assign({}, tsModule.sys, { fileExists(path) {
            if (util_1.isVirtualVueFile(path)) {
                return tsModule.sys.fileExists(path.slice(0, -'.ts'.length));
            }
            return tsModule.sys.fileExists(path);
        },
        readFile(path, encoding) {
            if (util_1.isVirtualVueFile(path)) {
                const fileText = tsModule.sys.readFile(path.slice(0, -'.ts'.length), encoding);
                return fileText ? preprocess_1.parseVueScript(fileText) : fileText;
            }
            const fileText = tsModule.sys.readFile(path, encoding);
            return fileText;
        } });
    if (tsModule.sys.realpath) {
        const realpath = tsModule.sys.realpath;
        vueSys.realpath = function (path) {
            if (util_1.isVirtualVueFile(path)) {
                return realpath(path.slice(0, -'.ts'.length)) + '.ts';
            }
            return realpath(path);
        };
    }
    return vueSys;
}
exports.getVueSys = getVueSys;
//# sourceMappingURL=vueSys.js.map