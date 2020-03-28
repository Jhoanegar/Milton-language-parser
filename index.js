const nearley = require("nearley");
const grammar = require("./grammar.js");

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
const input = `#Init
terminal when (Booting and not MiltonAllowed and not MiltonNotAllowed and
  (InTerminal_Ending_Gates or InTerminal_Ending_Crypt or InTerminal_Ending_Tower or
   InTerminal_Nexus_Floor1 or InTerminal_Nexus_Floor2 or InTerminal_Nexus_Floor3 or InTerminal_Nexus_Floor4) )
`
.replace(/\n[\t ]+/g, ' ')
.replace(/\u0023.*\n/g, '')


const empty = "";
// Parse something!
console.log(`\n===========\n${input}=============\n`);
parser.feed("not VariableName and OtherVariable or OtherVariable");

// parser.results is an array of possible parsings.
console.log("LENGTH: " + parser.results.length); // [[[[ "foo" ],"\n" ]]]
console.log(JSON.stringify(parser.results, null, 3)); // [[[[ "foo" ],"\n" ]]]