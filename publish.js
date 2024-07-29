import { exec } from 'child_process';
import { promisify } from 'util';
import { readdir } from 'fs';

const preaddir = promisify(readdir);
const execAsync = promisify(exec);

async function publishAll() {
  try {
    const files = await preaddir('./libs');
    for (const file of files) {
      try {
        const { stdout, stderr } = await execAsync(`wally publish --project-path ./libs/${file}`);
        console.log(`Success for ${file}: ${stdout}`);
        if (stderr) {
          console.error(`Error for ${file}: ${stderr}`);
        }
      } catch (err) {
        console.error(`Execution failed for ${file}: ${err}`);
      }
    }
  } catch (err) {
    console.error(`Failed to read directory: ${err}`);
  }
}

publishAll();
