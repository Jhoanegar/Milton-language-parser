const nearley = require("nearley");
const fs = require("fs");
const path = require("path");
const grammar = require("./grammar.js");
const argv = require('yargs').argv

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
// let input = 
// `include "Content/Talos/Databases/ComputerTerminalDialogs/${argv.in}"
// `
let input = 
`terminal when (CommPortal_Start){
  prompt: [[TTRS:TermDlg.MLA_CommPortal.Ln0044.0.text.ConnectingNetworkDrivesW3W3=Connecting network drives.%w3.%w3.%w3.%w3.%w3 %w9Error: network inaccessible.%s0%w9
  ###75639$ Encountered unknown errors
    
  Run MLA troubleshooter? [Y/N] ]]
    clear: CommPortal_FakeCLI
    options: {
      "TTRS:TermDlg.Common.YesShort=Y" short: "TTRS:TermDlg.Common.Yes2=Yes" next: CommPortal_StartMLA
      "TTRS:TermDlg.Common.NoShort=N" short: "TTRS:TermDlg.Common.No2=No" next: CommPortal_ResumeFakeCLI
    }
  }
  
`
input = input.replace(/^#.*\r?\n/g, '');
input = input.replace(/include "(.*)"/g, includeFile);
input = input.replace(/^#.*\r?\n/g, '');
input = input.replace(/\n[\t ]+/g, ' ');

function includeFile(match, file) {
  if (!match) {
    throw new Error("Expected name of file");
  }
  let basePath = path.resolve('./','bin');
  let fileName = path.basename(file);
  try {
    let include = fs.readFileSync(path.resolve(basePath, fileName)).toString().replace(/\uFEFF/g, '')
  
    return include.trim()
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
// console.log(`\n===========`)
// console.log(printSource(input));
// console.log(`=============\n`);

parser.feed(input);

// parser.results is an array of possible parsings.
// console.log(JSON.stringify(parser.results, null, 3)); // [[[[ "foo" ],"\n" ]]]
console.log("LENGTH: " + parser.results.length); // [[[[ "foo" ],"\n" ]]]
console.log("NODES: " + parser.results[0][0].length);

let results = parser.results[0];

let printValue = function(arr) {
  for (let i = 0; i < arr.length; i++) {
    const element = arr[i];
    if (Array.isArray(element)) {
      printValue(element)
    } else {
      // console.log(element)
    }
  }
  
}

fs.writeFileSync(argv.out, JSON.stringify(results[0], null, 2));

printValue(results);
