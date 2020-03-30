const nearley = require("nearley");
const fs = require("fs");
const path = require("path");
const grammar = require("./grammar.js");

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
let input = `#Init
terminal when (Booting and not MiltonAllowed and not MiltonNotAllowed and
  (InTerminal_Ending_Gates or InTerminal_Ending_Crypt or InTerminal_Ending_Tower or
   InTerminal_Nexus_Floor1 or InTerminal_Nexus_Floor2 or InTerminal_Nexus_Floor3 or InTerminal_Nexus_Floor4) ) { notext
  setlocal: MiltonNotAllowed
  goto: Booting
}
terminal when (Booting and not MiltonAllowed and not MiltonNotAllowed and not
  (InTerminal_Ending_Gates or InTerminal_Ending_Crypt or InTerminal_Ending_Tower or
   InTerminal_Nexus_Floor1 or InTerminal_Nexus_Floor2 or InTerminal_Nexus_Floor3 or InTerminal_Nexus_Floor4) ) { notext
  setlocal: MiltonAllowed
  goto: Booting
}

terminal when (Milton1_1 and not Milton1_1_DONE and Booting and MiltonAllowed){ notext
  setlocal: CLI_Blocked
  goto: Milton1_1_Start
}

terminal when (Milton1_1_Start) {
  prompt: [[TTRS:TermDlg.Milton1_1.Ln0007.0.text.AttentionPart2OfThe=Attention: Part 2 of the certification program has now been generated.%w5

Part 2 has been designed to test the consistency of some of your outlier responses in the previous round. You will be presented with a series of statements. Please indicate your agreement where appropriate.%w5

Begin? [Y/N] ]]

	options:{
  "TTRS:TermDlg.Common.YesShort=Y" short: "TTRS:TermDlg.Common.Yes2=Yes" next: part2q1
  "TTRS:TermDlg.Common.NoShort=N" short: "TTRS:TermDlg.Common.No2=No" next: CLI_Resume
	}
}
	
`
.replace(/include "(.*)"/g, includeFile);
input = input.replace(/\u0023.*\n/g, '\n');

function includeFile(match, file) {
  if (!match) {
    throw new Error("Expected name of file");
  }
  let basePath = path.resolve('./','bin');
  let fileName = path.basename(file);
  try {
    let include = fs.readFileSync(path.resolve(basePath, fileName)).toString()
  
    return include
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