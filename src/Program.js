const debug = require('debug')('milton');
const status = require('debug')('status');
const ask = require('enquirer').prompt
const type = require('node-typewriter')

const { AutoComplete } = require('enquirer');
const _ = require('lodash');
const Option = require('./Option');

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
        this.name = name;
        this.terminalOptions = [];
        this.nextInstruction;
    }

    async nextTick() {
        debugger;
        let prompt;
        let response;
        this.playerOptions = [];
        this.terminalOptions = [];
        if (this.stopped) {
            this.mainLoop.emit('endProgram');
        }

        if (this.nextInstruction) {
            let instruction = this.findNextInstruction();
            this.nextInstruction = null;
            prompt = this.processInstruction(instruction);
            
        } else {
            this.program.forEach(([currentInstruction]) => {
                debug(`currentInstruction: ${JSON.stringify(currentInstruction, null, 3)}`);
                if (!this.conditionsMet(currentInstruction[2]))
                    return true;
                prompt = this.processInstruction(currentInstruction, prompt);
            })
        }

        
        if (!prompt) {
            throw new Error("Inconsistent state. Not prompt found");
        }
        await this.printToConsole(prompt);
        if (this.terminalOptions.length >= 1) {
            if (this.playerOptions.length >= 1) {
                throw new Error(`Inconsistent state, shouldn't be player and terminal options.
                Player options: ${JSON.stringify(this.playerOptions, null, 3)}
                Terminal options: ${JSON.stringify(this.terminalOptions, null, 3)}`);
            }
            response = await this.getResponse(this.terminalOptions);
        } else if (this.playerOptions.length >= 1) {
            response = await this.getResponse(this.playerOptions);
        } else {
            this.stopped = true;
        };
        if (response) {
            this.mainLoop.emit('response', response);
        }
    }

    findNextInstruction() {
        debugger;
        let nextInstruction = _.find(this.program, ([currentInstruction]) => {
            let [statement, declaration, condition, params] = currentInstruction;
            return condition && Object.keys(condition).length === 1 && condition[this.nextInstruction] === true
        })

        if (!nextInstruction) {
            throw new Error(`Next instruction not found ${JSON.stringify(this.nextInstruction, null, 3)}`)
        }
        return nextInstruction[0];
    }

    processInstruction(currentInstruction, prompt) {
        this.updateInitialConditions(currentInstruction[3]);
        prompt = this.getPromptIfExists(currentInstruction[3]);
        this.findPlayerOptions(currentInstruction);
        this.findTerminalOptions(currentInstruction);
        return prompt;
    }

    async getResponse(options) {
        options = _.flattenDeep(options);
        let choices = options.map(option => _.clone(option.toAutoComplete()));
        let question = new AutoComplete({message: '>>', choices});
        let answer = await question.run();
        let response = this.getValuesForResponse(options, answer);
        this.updateInitialConditions(response);
        return response;
    }

    getPromptIfExists(args) {
        if (this.isNoText(args)) {
            return false;
        }
        let prompt = args.prompt || args.text
        return prompt;
    }

    findPlayerOptions(instruction) {
        if (!this.playerStatement(instruction)) {
            return undefined;
        }
        if (!instruction[3].options) {
            this.playerOptions.push(new Option(instruction[3]));
        } else {
            throw new Error("findPlayerOptions without options Not implemented yet");
        }
    }
    
    findTerminalOptions(instruction) {
        debug(`#findTerminalOptions: ${JSON.stringify(instruction, null, 3)}`);
        if (!this.terminalStatement(instruction)) {
            return undefined;
        }
        if (instruction[3].options) {
            let newOptions = instruction[3].options.map(option => {
                return new Option({text: option.prompt.text, operations: option.operations});
            })
            this.terminalOptions = [...this.terminalOptions, newOptions];
        } else {
            let newOption = new Option({text: instruction[3].prompt, operations: instruction[3].operations});
            this.terminalOptions = [...this.terminalOptions, newOption];
        }
    }

    isNoText(args) {
        debug(`#isNoText`)
        debug(`args: ${JSON.stringify(args, null, 3)}`);
        let notext = _.find(args.operations, operation => operation.notext === true);
        return !!notext
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
            result = await this.printToConsole(prompt);
        }
        if (options) {
            response = await this.printOptions(options);
        }
        this.updateInitialConditions(params);
        return response;
    }

    updateInitialConditions(response) {
        debug(`#updateInitialCondition: ${JSON.stringify(response, null, 3)}`);
        let operations = response.operations;
        if (!operations) {
            operations = [response];
        }
        operations.forEach(operation => {
            _.forOwn(operation, (value, key) => {
                switch(key) {
                    case 'next':
                        this.nextInstruction = value;
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


    getValuesForResponse(options, response) {
        debug(`options: ${JSON.stringify(options, null, 3)}`);
        debug(`response: ${JSON.stringify(response, null, 3)}`);
        let option = _.find(options, option => option.text == response)
        if (!option) {
            throw new Error(`Could not find values for ${JSON.stringify(response, null, 3)}`)
        }
        let values = {};
        option.operations.forEach(option => {
            _.forOwn(option, (value, key) => {
                if (key !== 'prompt' && key !== 'name') {
                    values[key] = value;
                }
            })
        });
        if (Object.keys(values).length === 0) {
            throw new Error(`Option is empty ${JSON.stringify(option, null, 3)}`)
        }
        debug(`Returning values: ${JSON.stringify(values, null, 3)}`);
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