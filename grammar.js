// Generated automatically by nearley, version 2.19.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }

let variables = {};
const moo = require("moo");
const trim = token => {token.trim()};
const lexer = moo.compile({
    _:      /[ \t]+/,
    NUMBER:  /0|[1-9][0-9]*/,
    STRING:  /"(?:\\["\\]|[^\n"\\])*"/,
    LPAREN:  {match: /\(\s?/, value: trim},
    LPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  '{',
    RBRACE:  '}',
    KEYWORD: [/'terminal'/, 'when'],
    NOT: [/not\s?/],
    AND: [/and\s?/],
    OR: [/or\s?/],
    NL:      { match: /\n/, lineBreaks: true },
    VARIABLE_NAME: { match: /[A-Z][a-z_A-Z0-9]+\s?/, value: trim},
    INSTRUCTION: ['notext']
});
var grammar = {
    Lexer: lexer,
    ParserRules: [
    {"name": "main", "symbols": ["exp"]},
    {"name": "exp$ebnf$1", "symbols": []},
    {"name": "exp$ebnf$1$subexpression$1", "symbols": [(lexer.has("OR") ? {type: "OR"} : OR), "term"]},
    {"name": "exp$ebnf$1", "symbols": ["exp$ebnf$1", "exp$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "exp", "symbols": ["term", "exp$ebnf$1"]},
    {"name": "term$ebnf$1", "symbols": []},
    {"name": "term$ebnf$1$subexpression$1", "symbols": [(lexer.has("AND") ? {type: "AND"} : AND), "factor"]},
    {"name": "term$ebnf$1", "symbols": ["term$ebnf$1", "term$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "term", "symbols": ["factor", "term$ebnf$1"]},
    {"name": "factor", "symbols": [(lexer.has("VARIABLE_NAME") ? {type: "VARIABLE_NAME"} : VARIABLE_NAME)]},
    {"name": "factor", "symbols": [(lexer.has("NOT") ? {type: "NOT"} : NOT), "factor"]},
    {"name": "factor", "symbols": [(lexer.has("LPAREN") ? {type: "LPAREN"} : LPAREN), "exp", (lexer.has("RPAREN") ? {type: "RPAREN"} : RPAREN)]}
]
  , ParserStart: "main"
}
if (typeof module !== 'undefined'&& typeof module.exports !== 'undefined') {
   module.exports = grammar;
} else {
   window.grammar = grammar;
}
})();
