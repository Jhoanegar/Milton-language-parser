import _ from "lodash";
import { EventEmitter } from "node:events";
import Enquirer from "enquirer";
import createDebugger from "debug";
import Program from "./Program.mjs";
import { promises as fs } from "node:fs";
import { dirname } from "path";
import { fileURLToPath } from "url";

const { prompt, AutoComplete } = Enquirer;
const __dirname = dirname(fileURLToPath(import.meta.url));

const debug = createDebugger("milton");
let initialConditions = {
  QueryMLA_START: true,
  QueryMLA_ON: true,
};
let mainLoop = new EventEmitter();
let program;
const programs = [
  {
    value: "1.QueryMLA",
  },
  {
    value: "2.MLA_CommPortal",
  },
];
let showMenu = true;
let menu = new AutoComplete({
  choices: programs,
  name: "program",
  message: "Programa a ejecutar",
});
(async () => {
  //initServer() // To stop the terminal from closing
  program = new Program({
    program: programs[0].program,
    mainLoop: mainLoop,
    initialConditions: programs[0].initialConditions,
  });
  mainLoop.on("operation", async (data) => {
    debug("Running operation...");
    await data;
  });
  mainLoop.on("response", async (data) => {
    await program.nextTick();
  });
  mainLoop.on("endProgram", async (endConditions) => {
    debugger;
    console.log("Endprogram: ", endConditions);
    initialConditions = endConditions;
    await runMenu();
  });
  mainLoop.on("endtick", async () => {
    debug("endtick");
    await program.nextTick();
  });
  await runMenu();
})();

async function runMenu() {
  let menu = new AutoComplete({
    choices: programs,
    name: "program",
    message: "Programa a ejecutar",
  });
  let results = await menu.run();
  program = new Program({
    program: await readFile(`../programs/${results}.json`),
    mainLoop,
    initialConditions,
  });
  return program.nextTick();
}

function initServer() {
  var net = require("net");

  var server = net.createServer(function (socket) {
    socket.write("Echo server\r\n");
    socket.pipe(socket);
  });

  server.listen(1337, "127.0.0.1");
}

const readFile = async (file) => {
  const text = await fs.readFile(`${__dirname}/${file}`, "utf-8");

  return JSON.parse(text);
};
