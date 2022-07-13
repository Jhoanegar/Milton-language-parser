import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promises as fs } from 'node:fs';
import Enquirer from 'enquirer';

import Program from '../Program.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));

const { AutoComplete } = Enquirer;

const showMenu = async ({ menuOptions, mainLoop, initialConditions }) => {
  let menu = new AutoComplete({
    choices: menuOptions,
    name: 'program',
    message: 'Programa a ejecutar',
  });
  let results = await menu.run();
  const program = new Program({
    program: await readFile(`../../programs/${results}.json`),
    mainLoop,
    initialConditions,
  });

  return program;
};

const readFile = async (file) => {
  const text = await fs.readFile(`${__dirname}/${file}`, 'utf-8');

  return JSON.parse(text);
};

export default showMenu;
