const nearley = require("nearley");
const fs = require("fs");
const path = require("path");
const grammar = require("./grammar.js");

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
let input = 
`include "Content/Talos/Databases/ComputerTerminalDialogs/QueryMLA.dlg"
include "Content/Talos/Databases/ComputerTerminalDialogs/MLA_CommPortal.dlg"
include "Content/Talos/Databases/ComputerTerminalDialogs/MiltonTower1.dlg"
include "Content/Talos/Databases/ComputerTerminalDialogs/MiltonTower2.dlg"
include "Content/Talos/Databases/ComputerTerminalDialogs/Milton1_1.dlg"
include "Content/Talos/Databases/ComputerTerminalDialogs/Milton1_2.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton2_1.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton2_2.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton2_3.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton2_4.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton2_5.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton2_6.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton3_1.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton3_2.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton3_3.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton3_4.dlg"
#include "Content/Talos/Databases/ComputerTerminalDialogs/Milton3_5.dlg"
`
input = input.replace(/^[^"]*#.*/g, '');
input = input.replace(/include "(.*)"/g, includeFile);
input = input.replace(/\n[\t ]+/g, ' ');

function includeFile(match, file) {
  if (!match) {
    throw new Error("Expected name of file");
  }
  let basePath = path.resolve('./','bin');
  let fileName = path.basename(file);
  try {
    let include = fs.readFileSync(path.resolve(basePath, fileName), 'utf8').toString().replace(/^\uFEFF/, '');
  
    return include.replace(/^[^"]*#.*/g, '').trim() + "\n"
  } catch (err) {
    throw err;
  }
}

function printSource(input) {
  let lines = input.split('\n');
  let output = "\n";
  lines.forEach((line, index) => {
    output = output.concat(`${index+1}:\t${line}\n`);
  })
  return output;
}
// Parse something!
console.log(`\n===========`)
console.log(printSource(input));
console.log(`=============\n`);

parser.feed(input);

// parser.results is an array of possible parsings.
//console.log(JSON.stringify(parser.results, null, 3)); // [[[[ "foo" ],"\n" ]]]
console.log("LENGTH: " + parser.results.length); // [[[[ "foo" ],"\n" ]]]
console.log("NODES: " + parser.results[0][0].length);