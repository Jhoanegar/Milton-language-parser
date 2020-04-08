const debug = require('debug')('milton');
const status = require('debug')('status');
const ask = require('enquirer').prompt
const type = require('node-typewriter')

const { AutoComplete } = require('enquirer');
const _ = require('lodash');

class Program {
    constructor({
        program,
        mainLoop,
        initialConditions,
        name,
        sleepMs=100,
        typeSpeed=100
    }) {
        this.program = program;
        this.PC = -1; // Program Counter
        this.mainLoop = mainLoop;
        this.playerOptions = [];
        this.initialConditions = initialConditions;
        this.sleepMs = sleepMs;
        this.typeSpeed = typeSpeed
        this.currentInstruction;
        this.stopped = false;
        this.instructionsNotMatched = 0;
        this.name = name
    }

    async nextTick() {
        if (this.name == '2.MLA_CommPortal') {
            debugger;
        }
        this.PC++;
        debug("Processing next Tick " + this.PC);
        status("State: ", JSON.stringify(this.initialConditions, null, 3));
        if (!this.program[this.PC]) {
            debug("Reset this.PC");
            await this.player();
            this.PC = 0;
            if (this.instructionsNotMatched >= this.program.length) {
                this.mainLoop.emit('endProgram', this.initialConditions);
                this.stopped = true;
            }
        }
        let instruction = this.program[this.PC][0];
        this.currentInstruction = instruction;
        let result = this.processInstruction(instruction);
        if (result.terminal) {
            await result.operation;
            instruction.consumed = true;
            debug("Queueing operation")
            this.mainLoop.emit('operation');
            this.PC = -1;
        } else {
            this.instructionsNotMatched++;
        }
        if (!this.stopped)
            this.mainLoop.emit('endtick');
    }

    processInstruction(instruction) {
        if (this.PC===20) {
            instruction;
        }
        if (instruction.consumed) {
            return {terminal: false};
        }
        if (this.terminalStatement(instruction) && this.conditionsMet(instruction[2])) {
            return {terminal: true, operation: this.terminal(instruction[3])};
        } else if (this.playerStatement(instruction) && this.conditionsMet(instruction[2])) {
            this.addPlayerStatement(instruction[3]);
            return {terminal: false}
        }

        return {terminal: false}
    }

    terminalStatement(instruction) {
        return instruction[0] && (instruction[0].type == "TERMINAL")
            && instruction[1] && instruction[1].type == 'WHEN'
            && instruction[2]
            && instruction[3]
    }

    playerStatement(instruction) {
        return instruction[0] && instruction[0].type == "PLAYER"
            && instruction[1] && instruction[1].type == 'WHEN'
            && instruction[2]
            && instruction[3]
    }

    conditionsMet(conditions, operator='and') {
        var met = operator === 'and' ? true : false;
        _.forOwn(conditions, (value, key) => {
            if (key === "$or") {
                met = met && this.conditionsMet(value, 'or')
            } else if (value === true && this.initialConditions[key] !== value && operator === 'and') {
                met = false;
                return false;
            } else if (value === false && this.initialConditions[key] === true && operator === 'and') {
                met = false;
                return false;
            } else if (this.initialConditions[key] === value && operator === 'or') {
                met = true;
                return false;
            }
        })
        return met;
    }

    async terminal(params) {
        let prompt = params.prompt || params.text;
        let options = params.options;
        let result = Promise.resolve();
        let response;
        if (prompt) {
            debug("Printing prompt");
            result = await this.printToConsole(prompt);
        }
        if (options) {
            debug("printint options");
            response = await this.printOptions(options);
        }
        this.updateInitialConditions(params);
        return response;
    }

    addPlayerStatement(statement) {
        this.playerOptions.push(statement);
        this.playerOptions = _.uniqBy(this.playerOptions, item => item.text || item.prompt)
    }

    async player() {
        let result = await this.printOptions(this.playerOptions, "player")
        if (result === false) {
            this.mainLoop.emit('programExit');
            this.mainLoop
        } else {
            this.instructionsNotMatched = 0;
        }
        this.playerOptions = [];
    }

    async printToConsole(message) {
        message = message.replace(/%../g, '').split('\\n');
        return message.reduce(async (previous, currentMessage) => {
            await previous;
            if (currentMessage.length == 0) {
                console.log("");
            } else {
                // await this.msleep(this.sleepMs);
                // return type(currentMessage + "\n", this.typeSpeed)
                console.log(currentMessage + "\n")
            }
        }, Promise.resolve())
    }

    async printOptions(options, source="terminal") {
        let adapter;
        if (source === "terminal") {
            adapter = option => option.prompt.text
        } else {
            adapter = option => option.text
        }
        let result = Promise.resolve();
        let choices = options.map(adapter);
        if (choices.length == 0) {
            return false;
        }
        let question = new AutoComplete({message: '>>', choices})
        let response = this.getValuesForResponse(options, await question.run(), source);
        this.updateInitialConditions(response);
        // this.mainLoop('response', response);
    }

    updateInitialConditions(response) {
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
                        this.initialConditions[value] = true;
                        break;
                    case 'prompt':
                    case 'options':
                        break;
                    case 'clear':
                        delete this.initialConditions[value]
                        break;
                    case 'notext':
                        break;
                    default:
                        throw new Error(`Key: ${key}:${value} not implemented yet`);
                }
            })
        })
    }

    getValuesForResponse(options, response, source) {
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

    msleep(n) {
        Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, n);
    }
    sleep(n) {
        msleep(n * 1000);
    }
}

module.exports = Program;