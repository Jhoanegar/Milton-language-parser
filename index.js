const nearley = require("nearley");
const fs = require("fs");
const path = require("path");
const grammar = require("./grammar.js");

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
let input = 
`terminal when (FakePasswordPrompt) {
  options:{
      "******" short: "TTRS:TermDlg.MLA_CommPortal.Ln0089.0.option.Qwerty=qwerty" next: falsepassword
      "***" short: "TTRS:TermDlg.MLA_CommPortal.Ln0090.0.option.God=god" next: falsepassword
      "*******" short: "TTRS:TermDlg.MLA_CommPortal.Ln0091.0.option.Letmein=letmein" next: falsepassword
      "********" short: "TTRS:TermDlg.MLA_CommPortal.Ln0092.0.option.Trustno1=trustno1" next: falsepassword
      "*****" short: "TTRS:TermDlg.Common.Admin=admin" next: falsepassword
    }
  }
`
input = input.replace(/#.*\r?\n/g, '');
input = input.replace(/include "(.*)"/g, includeFile);
input = input.replace(/#.*\r?\n/g, '');
input = input.replace(/\n[\t ]+/g, ' ');

function includeFile(match, file) {
  if (!match) {
    throw new Error("Expected name of file");
  }
  let basePath = path.resolve('./','bin');
  let fileName = path.basename(file);
  try {
    let include = fs.readFileSync(path.resolve(basePath, fileName)).toString()
  
    return include.trim() + "\n"
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
console.log(JSON.stringify(parser.results, null, 3)); // [[[[ "foo" ],"\n" ]]]
console.log("LENGTH: " + parser.results.length); // [[[[ "foo" ],"\n" ]]]
console.log("NODES: " + parser.results[0][0].length);