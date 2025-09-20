import { type Plugin } from 'vite';
import fs from 'fs';
import path from 'path';

interface UpdateResumeOptions {
  sourceDirectories: string[];
}

export default function UpdateResume(options: UpdateResumeOptions): Plugin {
  const { sourceDirectories } = options;
  const outputDirectory= path.resolve('./static');

  return {
    name: 'update-resume',
    apply: 'build',
    async buildStart() {
      try {
        fs.mkdirSync(outputDirectory, { recursive: true });
        for (const sourceDirectory of sourceDirectories)
          fs.cpSync(sourceDirectory, outputDirectory, {recursive: true});
        console.log(`[FetchJSONResume] Saved Resume to: ${outputDirectory}`);
      } catch (error) {
        console.error(`[FetchJSONResume] Error:`, error);
      }
    },
  };
}
