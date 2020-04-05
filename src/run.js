const debug = require('debug')('milton');
const ask = require('enquirer').prompt
const { AutoComplete } = require('enquirer');
const type = require('node-typewriter')
const _ = require('lodash')
const { EventEmitter } = require('events')
const program = require('../output.json')
const initialConditions = {
    QueryMLA_START: true
};

let mainLoop = new EventEmitter();
(async () => {
    //initServer() // To stop the terminal from closing
    mainLoop.on('operation', async data => {
        debug("Running operation...");
        await data;
    })
    mainLoop.on('response', async data => {
        debug(`Initial Contitions: ${JSON.stringify(initialConditions,null, 3)}`)

        nextTick()
    })
    nextTick()
})();

function nextTick() {
    debug("Processing next Tick");
    let i = 0;
    let result;
    while (program[i]) {
        let instruction = program[i][0];
        let result = processInstruction(instruction);
        if (result) {
            instruction.consumed = true;
            debug("Queueing operation")
            mainLoop.emit('operation', result);
            break;
        }
        i++
    }
}

function processInstruction(instruction) {
    debugger;
    if (instruction.consumed) {
        return;
    }
    if (terminalStatement(instruction) && conditionsMet(instruction[2])) {
        return terminal(instruction[3]);
    }
}

function terminalStatement(instruction) {
    return instruction[0] && instruction[0].type == "TERMINAL"
        && instruction[1] && instruction[1].type == 'WHEN'
        && instruction[2]
        && instruction[3]
}

function conditionsMet(conditions) {
    var conditionsMet = true;
    _.forOwn(conditions, (value, key) => {
        if (initialConditions[key] != value) {
            conditionsMet = false;
            return false;
        }
    })
    return conditionsMet;
}

async function terminal({ prompt, options }) {

    let result = Promise.resolve();
    if (prompt) {
        debug("Printing prompt");
        result = await printToConsole(prompt);
    }
    if (options) {
        debug("printint options");
        response = await printOptions(options);
    }
    return response;
}

async function printToConsole(message) {
    message = message.replace(/%../g, '').split('\\n');
    return message.reduce(async (previous, currentMessage) => {
        await previous;
        if (currentMessage.length == 0) {
            console.log("");
        } else {
            await sleep(1)
            return type(currentMessage + "\n", '200')
        }
    }, Promise.resolve())
}

async function printOptions(options) {
    let result = Promise.resolve();
    let choices = options.map(option => option.prompt.text);
    let question = new AutoComplete({message: '>>', choices})
    let response = getValuesForResponse(options, await question.run());
    updateInitialConditions(response);
    mainLoop.emit('response', response);
}

function updateInitialConditions(response) {
    _.forOwn(response, (value, key) => {
        switch(key) {
            case 'next':
            case 'set':
            case 'setlocal':
                initialConditions[value] = true;
                break;
            default:
                throw new Error(`Key: ${key}:${value} not implemented yet`);
        }
    })
}

function getValuesForResponse(options, response) {
    let option = _.find(options, option => option.prompt.text == response)
    let values = {};
    _.forOwn(option, (value, key) => {
        if (key != 'prompt') {
            values[key] = value;
        }
    })
    return values
    
}

function msleep(n) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, n);
}
function sleep(n) {
    msleep(n * 1000);
}


function initServer() {
    var net = require('net');

    var server = net.createServer(function(socket) {
        socket.write('Echo server\r\n');
        socket.pipe(socket);
    });
    
    server.listen(1337, '127.0.0.1');
}