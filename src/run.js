const debug = require('debug')('miltons');
const {prompt} = require('enquirer')
const type = require('node-typewriter')
const _ = require('lodash')
const {EventEmitter}= require('events')
const program = require('../output.json')
const initialConditions = {
    QueryMLA_START: true
};

let mainLoop = new EventEmitter();
(async () => {
    mainLoop.on('operation', async data => {
        debug("Running operation...");
        await data;
    })
    process.stdin.resume();
    nextTick()
})();
 
function nextTick() {   
    debugger; 
    let i = 0;
    let result;
    while(program[i]) {
        debug("Processing next Tick");
        let result = processInstruction(program[i][0]);
        if (result) {
            mainLoop.emit('operation', result);
            break;
        }
        i++
    }
}

function processInstruction(instruction) {
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

 async function terminal({prompt, options}) {
     if (prompt) {
        let message = prompt.replace(/%../g,'').split('\\n');
        return message.reduce(async(previous, currentMessage) => {
            await previous;
            if (currentMessage.length == 0) {
                console.log("");
            } else {
                await sleep(1)
                return type(currentMessage+"\n", '1000')
            }
        })
     }
 }

 function msleep(n) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, n);
  }
  function sleep(n) {
    msleep(n*1000);
  }


