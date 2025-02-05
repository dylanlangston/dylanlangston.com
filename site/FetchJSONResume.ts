import { type Plugin } from 'vite';
import fs from 'fs';
import path from 'path';

interface FetchJSONResumeOptions {
  url: string;
  filename?: string;
}

export default function fetchJSONResume(options: FetchJSONResumeOptions): Plugin {
  const { url, filename = 'resume.json' } = options;
  const outputPath = path.resolve('./static', filename);

  return {
    name: 'fetch-json-resume',
    apply: 'build',
    async buildStart() {
      try {
        console.log(`[FetchJSONResume] Fetching JSON from: ${url}`);
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`Failed to fetch JSON: ${response.statusText}`);
        }
        const json = await response.json();
        
        fs.mkdirSync(path.dirname(outputPath), { recursive: true });
        fs.writeFileSync(outputPath, JSON.stringify(json, null, 2), 'utf-8');
        console.log(`[FetchJSONResume] Saved JSON to: ${outputPath}`);
      } catch (error) {
        console.error(`[FetchJSONResume] Error:`, error);
      }
    },
  };
}
