const debug = require('debug')('milton');
const status = require('debug')('status');
const _ = require('lodash')
const { EventEmitter } = require('events')
const {prompt, AutoComplete} = require('enquirer');
const Program = require('./Program');
let initialConditions = {
    QueryMLA_START: true,
    QueryMLA_ON: true,
    "Milton1_1_Start": true // Milton_1_1
};
let secondaryConditions = {
    QueryMLA_START: true,
    Nonsense_QueryMLA: true,
    WhatHelp: true,
    EngagedMLA_QueryMLA: true,
    FirstWord_DONE: true,
    QueryFailed: true,
    Offence_DONE: true,
    Offence: true,
    Describe_DONE: true,
    Describe: true,
    HowOld_DONE: true,
    HowOld: true,
    WhatTerminal_DONE: true,
    WhatTerminal: true,
    HowLong_DONE: true,
    HowLong: true,
    WhatStatus_DONE: true,
    WhatStatus: true,
    Corruption_DONE: true,
    Corruption: true,
    OutsideWorld: true,
    OutsideWorld_DONE: true,
    WhoElohimQuery_DONE: true,
    WhoElohimQuery: true,
    WhatAmIQuery_DONE: true,
    WhatAmIQuery: true,
    WhereAmIQuery_DONE: true,
    WhereAmIQuery: true,
    MLAIntro_PhaseBusy: true,
    CLI_Resume: true,
    MLAIntro_PhaseCommPortal: true,
    Booting: true,
    MiltonAllowed: true
}
let mainLoop = new EventEmitter();
let program;
const programs = [
    {
        value: '1.QueryMLA',
    },
    {
        value: '2.MLA_CommPortal',
    },
    {
        value: '3.Milton1_1',
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
        initialConditions = _.merge(endConditions,{
            "MLAIntro_PhaseCommPortal": true,
            "Booting": true,
            "CommPortal_Cert_COMPLETED": false,
            "MiltonAllowed": true,
            "CommPortal_AccessedByOtherUser": true
        });
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
        initialConditions,
        name: results
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