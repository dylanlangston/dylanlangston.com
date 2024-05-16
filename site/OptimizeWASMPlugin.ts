import { type Plugin } from 'vite';
import fs from 'fs';
import path from 'path';
import Binaryen from 'binaryen';

function optimizeWasm(code: Uint8Array) {
    const module = Binaryen.readBinary(code);
    Binaryen.setDebugInfo(false);
    module.setFeatures(Binaryen.Features.All);
    Binaryen.setLowMemoryUnused(true);
    Binaryen.setOptimizeLevel(3);
    Binaryen.setShrinkLevel(3);
    module.runPasses(["post-emscripten", "flatten", "rereloop"]);

    function runPass() {
      module.optimize();
      module.validate();
    }

    let lastBinary: Uint8Array | null = null;
    let i = 0;
    while (i < 3) {
      runPass();

      const binary = module.emitBinary();
      //console.log("Last Binary Size: " + lastBinary?.length + " - Binary size: " + binary.length + " - i:" + i);
      if (binary.length >= (lastBinary?.length ?? Number.MAX_VALUE)) {
        i++;
        continue;
      };

      i = 0;
      lastBinary = binary;
    }

    return lastBinary;
}

async function getFiles(folderPath: string): Promise<string[]> {
  return new Promise((resolve, reject) => {
    fs.access(folderPath, fs.constants.F_OK, (err) => {
      if (err) {
        resolve([]);
        return;
      }

      fs.readdir(folderPath, (err, files) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(files.filter(file => fs.statSync(path.join(folderPath, file)).isFile()));
      });
    });
  });
}

async function readWasmFile(filePath: string): Promise<Uint8Array> {
  return new Promise<Uint8Array>((resolve, reject) => {
    fs.readFile(filePath, (err, data) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(new Uint8Array(data));
    });
  });
}

export default function optimizeWASMPlugin({enabled = true}): Plugin {
  let outputFolder: string;
  return {
    name: 'optimize-wasm-files',
    configResolved(config) {
      outputFolder = config.build.outDir;
    },
    async closeBundle() {
      if (!enabled) return;

      const staticFolderPath = outputFolder;
      const staticFiles = await getFiles(staticFolderPath);

      for (let filename of staticFiles) {

        // Optimize the wasm code
        if (filename.endsWith('.wasm')) {
            this.info("Optimizing WASM file: " + filename);
            const fullPath = path.join(staticFolderPath, filename);
            const wasmCode = await readWasmFile(fullPath);
            const optimizedCode = optimizeWasm(wasmCode);
            fs.writeFileSync(fullPath, optimizedCode, 'binary');
        }
      }
      return;
    }
  };
}

