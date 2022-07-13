import { promises as fs } from 'node:fs';
import path from 'node:path';
import nearley from 'nearley';
import grammar from './grammar';
import yargs from 'yargs';

const argv = yargs.argv;

// Create a Parser object from our grammar.
const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
let input = `include "Content/Talos/Databases/ComputerTerminalDialogs/${argv.in}"
`;
input = input.replace(/^#.*\r?\n/g, '');
input = input.replace(/include "(.*)"/g, includeFile);
input = input.replace(/^#.*\r?\n/g, '');
input = input.replace(/\n[\t ]+/g, ' ');

const includeFile = async (match, file) => {
  if (!match) {
    throw new Error('Expected name of file');
  }
  const basePath = path.resolve('./', 'bin');
  const fileName = path.basename(file);
  const filepath = path.resolve(basePath, fileName);
  try {
    const include = (await fs.readFile(filepath))
      .toString()
      .replace(/\uFEFF/g, '');

    return include.trim();
  } catch (err) {
    console.error(err);
    throw err;
  }
};

function printSource(input) {
  let lines = input.split('\n');
  let output = '\n';
  lines.forEach((line, index) => {
    output = output.concat(`${index + 1}:\t${line}\n`);
  });
  return output;
}
// Parse something!
// console.log(`\n===========`)
// console.log(printSource(input));
// console.log(`=============\n`);

parser.feed(input);

// parser.results is an array of possible parsings.
// console.log(JSON.stringify(parser.results, null, 3)); // [[[[ "foo" ],"\n" ]]]
console.log('LENGTH: ' + parser.results.length); // [[[[ "foo" ],"\n" ]]]
console.log('NODES: ' + parser.results[0][0].length);

let results = parser.results[0];

let printValue = function (arr) {
  for (let i = 0; i < arr.length; i++) {
    const element = arr[i];
    if (Array.isArray(element)) {
      printValue(element);
    } else {
      // console.log(element)
    }
  }
};

fs.writeFileSync(argv.out, JSON.stringify(results[0], null, 2));

printValue(results);
