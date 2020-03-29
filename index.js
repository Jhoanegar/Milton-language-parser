const nearley = require("nearley");
const fs = require("fs");
const path = require("path");
const grammar = require("./grammar.js");

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
const input = `#Init
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
	
terminal when (part2q1 and humanbeing){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0022.0.text.3W52W51=3...%w5
2...%w5
1...%w5

-------------------------------

Q1 of 7
"Since all human beings are persons, and some human beings have psychological capacities similar to animals, some animals are therefore persons."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q2 set: animalsarepersons
	"TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q2 set: Milton1_2PersonDenial
	}
}

terminal when (part2q1 and citizen){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0039.0.text.3W102W101=3...%w10
2...%w10
1...%w10

-------------------------------

Q1 of 7
"Since only citizens can be persons, a hermit cannot be a person."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q2
	"TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q2 set: Milton1_2PersonDenial
	}
}

terminal when (part2q1 and negativeentropy){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0056.0.text.3W102W101=3...%w10
2...%w10
1...%w10

-------------------------------

Q1 of 7
"Since negative entropy indicates personhood, microscopic organisms are also persons."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q2
	"TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q2 set: Milton1_2PersonDenial
	}
}

terminal when (part2q1 and rationalanimal){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0073.0.text.3W102W101=3...%w10
2...%w10
1...%w10

-------------------------------

Q1 of 7
"Since only animals can be persons, a machine could never be a person."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q2
	"TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q2 set: Milton1_2PersonDenial
	}
}

terminal when (part2q1 and problemsolving){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0090.0.text.3W102W101=3...%w10
2...%w10
1...%w10

-------------------------------

Q1 of 7
"Since a person is merely a problem solving system, we could in principle build a person out of bits of string and tin cans."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q2
	"TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q2 set: Milton1_2PersonDenial
	}
}

terminal when (part2q2){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0107.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Q2 of 7
"A person is under no authority other than that to which they consent."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Milton1_1.Ln0116.0.option.IBroadlyAgree=I broadly agree" next: part2q3 short: "TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" set: Milton1_2NoMorals
	"TTRS:TermDlg.Milton1_1.Ln0117.0.option.IBroadlyDisagree=I broadly disagree" short: "TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q3
	}
}

terminal when (part2q3){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0122.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Q3 of 7
"The quality of life of persons ought be maximised."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Milton1_1.Ln0131.0.option.Agreed=Agreed" short: "TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q4 set: Milton1_2Utilitarian
	"TTRS:TermDlg.Milton1_1.Ln0132.0.option.IDisagree=I disagree" short: "TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q4
	}
}
terminal when (part2q4){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0136.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Q4 of 7
"Value is discovered."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Milton1_1.Ln0145.0.option.ISupposeSo=I suppose so" short: "TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q5 set: Milton1_2ValueDiscovered
	"TTRS:TermDlg.Milton1_1.Ln0146.0.option.ImNotSoSure=I'm not so sure" short: "TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q5
	}
}

terminal when (part2q5){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0151.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Q5 of 7
"Persons deserve the talents they were born into."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Common.Yes2=Yes" short: "TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q6
	"TTRS:TermDlg.Common.No2=No" short: "TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q6
	}
}

terminal when (part2q6){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0166.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Q6 of 7
"The liberty of persons ought be maximised."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Milton1_1.Ln0175.0.option.ThatsCorrect=That's correct" short: "TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2q7 set: Milton1_2Liberal
	"TTRS:TermDlg.Milton1_1.Ln0176.0.option.ThatsNotCorrect=That's not correct" short: "TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2q7
	}
}

terminal when (part2q7){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0181.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Q7 of 7
"Value is created."

ANSWER: ]]
	options:{
	"TTRS:TermDlg.Milton1_1.Ln0190.0.option.Confirmed=Confirmed" short: "TTRS:TermDlg.Common.BroadlyAgree=Broadly agree" next: part2end set: Milton1_2ValueCreated
	"TTRS:TermDlg.Milton1_1.Ln0191.0.option.IDontAgree=I don't agree" short: "TTRS:TermDlg.Common.BroadlyDisagree=Broadly disagree" next: part2end
	}
}

terminal when (part2end){
prompt: [[TTRS:TermDlg.Milton1_1.Ln0196.0.text.YourInputHasBeenAccepted=Your input has been accepted.

-------------------------------%w5

Thank you. The certification process is now complete. You will receive a notification when your user profile has been generated.

Press any key to exit. ]]
set: Milton1_1_DONE
	options: {
	" " short:"TTRS:TermDlg.Common.Exit=exit" next: CLI_Resume  # once the cert is completed, this terminal will continue functioning for normal file viewing
	}
}



`
.replace(/include "(.*)"/g, includeFile)
.replace(/\n[\t ]+/g, ' ')
.replace(/\u0023.*\n/g, '')

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