const debug = require('debug')('milton');
const status = require('debug')('status');
const ask = require('enquirer').prompt
const { AutoComplete } = require('enquirer');
const type = require('node-typewriter')
const _ = require('lodash')
const { EventEmitter } = require('events')
const program = require('../output.json')
const initialConditions = {
    QueryMLA_START: true,
    QueryMLA_ON: true
};

let mainLoop = new EventEmitter();
let PI = 0;
let instructionsTotal = program[0].length;
let playerOptions = [];
let expectingPlayer = false;
(async () => {
    //initServer() // To stop the terminal from closing
    mainLoop.on('operation', async data => {
        debug("Running operation...");
        await data;
    })
    mainLoop.on('response', async data => {
        await nextTick()
    })
    mainLoop.on('endtick', () => {
       debug("endtick") 
        PI++;
       nextTick();
    })
    await nextTick()
})();

async function nextTick() {
    debug("Processing next Tick " + PI);
    status("State: ", JSON.stringify(initialConditions, null, 3));
    if (!program[PI]) {
        debug("Reset PI");
        await player();
        PI = 0;
    }
    instruction = program[PI][0];

    let result = processInstruction(instruction);
    if (result.terminal) {
        await result.operation;
        instruction.consumed = true;
        debug("Queueing operation")
        mainLoop.emit('operation');
        pi = -1;
    }
    mainLoop.emit('endtick');
}

function processInstruction(instruction) {
    if (PI===20) {
        instruction;
    }
    if (instruction.consumed) {
        return {terminal: false};
    }
    if (terminalStatement(instruction) && conditionsMet(instruction[2])) {
        return {terminal: true, operation: terminal(instruction[3])};
    } else if (playerStatement(instruction) && conditionsMet(instruction[2])) {
        playerOptions.push(instruction[3]);
        return {terminal: false}
    }

    return {terminal: false}
}

function terminalStatement(instruction) {
    return instruction[0] && (instruction[0].type == "TERMINAL")
        && instruction[1] && instruction[1].type == 'WHEN'
        && instruction[2]
        && instruction[3]
}

function playerStatement(instruction) {
    return instruction[0] && instruction[0].type == "PLAYER"
        && instruction[1] && instruction[1].type == 'WHEN'
        && instruction[2]
        && instruction[3]
}

function conditionsMet(conditions, operator='and') {
    var met = operator === 'and' ? true : false;
    _.forOwn(conditions, (value, key) => {
        if (key === "$or") {
            met = met && conditionsMet(value, 'or')
        } else if (value === true && initialConditions[key] !== value && operator === 'and') {
            met = false;
            return false;
        } else if (value === false && initialConditions[key] === true && operator === 'and') {
            met = false;
            return false;
        } else if (initialConditions[key] === value && operator === 'or') {
            met = true;
            return false;
        }
    })
    return met;
}

async function terminal(params) {
    let { prompt, options } = params;
    let result = Promise.resolve();
    if (prompt) {
        debug("Printing prompt");
        result = await printToConsole(prompt);
    }
    if (options) {
        debug("printint options");
        response = await printOptions(options);
    }
    updateInitialConditions(params);    
    return response;
}

async function player() {
    await printOptions(playerOptions, "player")
    playerOptions = [];
}

async function printToConsole(message) {
    message = message.replace(/%../g, '').split('\\n');
    return message.reduce(async (previous, currentMessage) => {
        await previous;
        if (currentMessage.length == 0) {
            console.log("");
        } else {
            await msleep(100);
            return type(currentMessage + "\n", '200')
        }
    }, Promise.resolve())
}

async function printOptions(options, source="terminal") {
    let adapter;
    if (source === "terminal") {
        adapter = option => option.prompt.text
    } else {
        adapter = option => option.text
    }
    let result = Promise.resolve();
    let choices = options.map(adapter);
    let question = new AutoComplete({message: '>>', choices})
    let response = getValuesForResponse(options, await question.run(), source);
    updateInitialConditions(response);
    // mainLoop.emit('response', response);
}

function updateInitialConditions(response) {
    if (!response.operations) {
        return
    }
    response.operations.forEach(operation => {
        _.forOwn(operation, (value, key) => {
            switch(key) {
                case 'next':
                case 'set':
                case 'setlocal':
                case 'goto':
                    initialConditions[value] = true;
                    break;
                case 'prompt':
                case 'options':
                    break;
                case 'clear':
                    delete initialConditions[value]
                    break;
                default:
                    throw new Error(`Key: ${key}:${value} not implemented yet`);
            }
        })
    })
}

function getValuesForResponse(options, response, source) {
    let option;
    if (source === "terminal") {
        option = _.find(options, option => option.prompt.text == response)
    } else {
        option = _.find(options, option => option.text == response)
    }
    let values = {};
    _.forOwn(option, (value, key) => {
        if (key !== 'prompt' && key !== 'text') {
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