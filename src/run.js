const debug = require('debug')('milton');
const status = require('debug')('status');
const _ = require('lodash')
const { EventEmitter } = require('events')
const {prompt, AutoComplete} = require('enquirer');
const Program = require('./Program');
let initialConditions = {
    QueryMLA_START: true,
    QueryMLA_ON: true
};
let mainLoop = new EventEmitter();
let program;
const programs = [
    {
        value: '1.QueryMLA',
    },
    {
        value: '2.MLA_CommPortal',
    }
];
let showMenu = true;
let menu = new AutoComplete({choices: programs, name: 'program', message: 'Programa a ejecutar'});
(async () => {
    //initServer() // To stop the terminal from closing
    program = new Program({
        program: programs[0].program,
        mainLoop: mainLoop,
        initialConditions: programs[0].initialConditions
    });
    mainLoop.on('operation', async data => {
        debug("Running operation...");
        await data;
    })
    mainLoop.on('response', async data => {
        await program.nextTick()
    })
    mainLoop.on('endProgram',async (endConditions) => {
        debugger;
        console.log("Endprogram: ", endConditions)
        initialConditions = endConditions;
        await runMenu()
    })
    mainLoop.on('endtick', async() => {
        debug("endtick")
        await program.nextTick();
    })
    await runMenu();
})();


async function runMenu() {
    let menu = new AutoComplete({choices: programs, name: 'program', message: 'Programa a ejecutar'});
    let results = (await menu.run());
    program = new Program({
        program: require(`../programs/${results}.json`),
        mainLoop,
        initialConditions
    });
    return program.nextTick();
}


function initServer() {
    var net = require('net');

    var server = net.createServer(function (socket) {
        socket.write('Echo server\r\n');
        socket.pipe(socket);
    });

    server.listen(1337, '127.0.0.1');
}