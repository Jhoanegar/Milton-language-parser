import { EventEmitter } from 'node:events';
import createDebugger from 'debug';

import Program from './Program.mjs';
import { showMenu } from './terminalHelpers/index.mjs';

const debug = createDebugger('milton');

let initialConditions = {
  QueryMLA_START: true,
  QueryMLA_ON: true,
};
let mainLoop = new EventEmitter();
let program;
let programs = [
  {
    value: '1.QueryMLA',
  },
  {
    value: '2.MLA_CommPortal',
  },
];

(async () => {
  program = new Program({
    program: programs[0].program,
    mainLoop: mainLoop,
    initialConditions: programs[0].initialConditions,
  });
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
    await showMenu({ programs, mainLoop, initialConditions });
  });
  mainLoop.on('endtick', async () => {
    debug('endtick');
    await program.nextTick();
  });

  program = await showMenu({ programs, mainLoop, initialConditions });
  debug('New Program', program);
})();
