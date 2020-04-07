const debug = require('debug')('milton');
const status = require('debug')('status');
const _ = require('lodash')
const { EventEmitter } = require('events')
const {prompt} = require('enquirer');
const Program = require('./Program');

let mainLoop = new EventEmitter();
let program;
const programs = [
    {
        program: require('../output.json'),
        name: '1. MLA Query',
        initialConditions : {
            QueryMLA_START: true,
            QueryMLA_ON: true
        }
    }
];


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
    mainLoop.on('endtick', () => {
        debug("endtick")
        program.nextTick();
    })

    await program.nextTick();

})();



function initServer() {
    var net = require('net');

    var server = net.createServer(function (socket) {
        socket.write('Echo server\r\n');
        socket.pipe(socket);
    });

    server.listen(1337, '127.0.0.1');
}