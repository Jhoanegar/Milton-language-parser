import { EventEmitter } from 'node:events';
import createDebugger from 'debug';

import Program from './Program.mjs';
import { showMenu } from './terminalHelpers/index.mjs';

const debug = createDebugger('milton');

let initialConditions = {
  QueryMLA_START: true,
  QueryMLA_ON: true,
  // phase 2
  MLAIntro_PhaseCommPortal: true,
  Booting: true,
  CommPortal_Cert_COMPLETED: false,
  MiltonAllowed: true,
};
let mainLoop = new EventEmitter();
let program;
const menuOptions = [
  {
    value: '1.QueryMLA',
  },
  {
    value: '2.MLA_CommPortal',
  },
];

(async () => {
  mainLoop.on('operation', async (data) => {
    debug('Running operation...');
    await data;
  });
  mainLoop.on('response', async () => {
    await program.nextTick();
  });
  mainLoop.on('endProgram', async (endConditions) => {
    console.log('Endprogram: ', endConditions);
    initialConditions = endConditions;
    program = await showMenu({ menuOptions, mainLoop, initialConditions });
  });
  mainLoop.on('endtick', async () => {
    debug('endtick');
    await program.nextTick();
  });

  program = await showMenu({
    menuOptions,
    mainLoop,
    initialConditions,
  });
  await program.nextTick();
})();
