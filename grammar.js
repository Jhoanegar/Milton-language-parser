// Generated automatically by nearley, version 2.19.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }

let variables = {};
const moo = require("moo");
const trim = token => {
    console.log(`"${token}"`)
    return token.trim()
};
const string = token => {
    var regex = /\[\[([\w:\.])*=?([\s\S](?!\]\]))+\s\]\]/ // Same regexp but with a capture group
    let match = token.match(regex)
    return {string: match[2], name: match[1]};
}
const optString = token => {
    var regex = /"([\s\S]*)=*([a-z\?,: '\*_A-Z0-9]+)"/;
    let match = token.match(regex);
    if (match && match[1] && match[2]) {
        return {string: match[2], name: match[1]}
    } else {
        return {string: ' ', name: ' '}
    }
}
const lexer = moo.compile({
    _:      /[ \t]+/,
    NUMBER:  /0|[1-9][0-9]*/,
    EMPTY_STRING: /" " /,
    OPT_STRING:  {match: /"[\w:\.]*=?[a-z\?\.,: \*'_A-Z0-9]+"/, value: optString},
    PROMPT_STRING:  {match: /\[\[[\w:\.]*=(?:[\s\S](?!\]\]))+\s\]\]/, value: string},
    LPAREN:  {match: /\(\s?/, value: trim},
    RPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  {match: /\{\s*/, value: trim},
    RBRACE:  {match: /\}[ \t]?/, value: trim},
    TERMINAL: {match: /terminal\s?/, value: trim},
    PLAYER: {match: /player\s?/, value: trim},
    COLON: {match: /\:\s?/, value: trim},
    KEYWORD: {match: [/short\s?/, /next\s?/, /clear\s?/, /notext\s?/, /goto\s?/, /setlocal\s?/, /prompt\s?/, /text\s?/, /set\s?/,], value:trim},
    OPTIONS: {match: [/options\s?/], value: trim},
    WHEN: {match: /when\s?/, value: trim},
    NOT: [/not[\s\t]?/],
    AND: [/and[\s\t]?/],
    OR: [/or\s?/],
    NL:  { match: /\r?\n/, lineBreaks: true },
    IDENT: { match: /[a-z_A-Z0-9]+\s*/, value: trim},
    INSTRUCTION: ['notext']
});
var grammar = {
    Lexer: lexer,
    ParserRules: [
    {"name": "main$ebnf$1", "symbols": []},
    {"name": "main$ebnf$1$subexpression$1", "symbols": ["stmt"]},
    {"name": "main$ebnf$1$subexpression$1", "symbols": ["exp"]},
    {"name": "main$ebnf$1", "symbols": ["main$ebnf$1", "main$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "main", "symbols": ["main$ebnf$1"]},
    {"name": "stmt", "symbols": [(lexer.has("TERMINAL") ? {type: "TERMINAL"} : TERMINAL), (lexer.has("WHEN") ? {type: "WHEN"} : WHEN), "exp", "termblock"]},
    {"name": "stmt", "symbols": [(lexer.has("PLAYER") ? {type: "PLAYER"} : PLAYER), (lexer.has("WHEN") ? {type: "WHEN"} : WHEN), "exp", "termblock"]},
    {"name": "termblock$ebnf$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "termblock$ebnf$1", "symbols": ["termblock$ebnf$1", (lexer.has("NL") ? {type: "NL"} : NL)], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "termblock", "symbols": [(lexer.has("LBRACE") ? {type: "LBRACE"} : LBRACE), "termstmt", (lexer.has("RBRACE") ? {type: "RBRACE"} : RBRACE), "termblock$ebnf$1"]},
    {"name": "termstmt$ebnf$1", "symbols": []},
    {"name": "termstmt$ebnf$1$subexpression$1", "symbols": ["action"]},
    {"name": "termstmt$ebnf$1", "symbols": ["termstmt$ebnf$1", "termstmt$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "termstmt", "symbols": ["action", "termstmt$ebnf$1"]},
    {"name": "action", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD)]},
    {"name": "action", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("IDENT") ? {type: "IDENT"} : IDENT)]},
    {"name": "action$ebnf$1", "symbols": []},
    {"name": "action$ebnf$1$subexpression$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "action$ebnf$1$subexpression$1", "symbols": [(lexer.has("_") ? {type: "_"} : _)]},
    {"name": "action$ebnf$1", "symbols": ["action$ebnf$1", "action$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "action", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("PROMPT_STRING") ? {type: "PROMPT_STRING"} : PROMPT_STRING), "action$ebnf$1"]},
    {"name": "action$ebnf$2", "symbols": []},
    {"name": "action$ebnf$2$subexpression$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "action$ebnf$2$subexpression$1", "symbols": [(lexer.has("_") ? {type: "_"} : _)]},
    {"name": "action$ebnf$2", "symbols": ["action$ebnf$2", "action$ebnf$2$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "action", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("OPT_STRING") ? {type: "OPT_STRING"} : OPT_STRING), "action$ebnf$2"]},
    {"name": "action$ebnf$3", "symbols": []},
    {"name": "action$ebnf$3$subexpression$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "action$ebnf$3$subexpression$1", "symbols": [(lexer.has("_") ? {type: "_"} : _)]},
    {"name": "action$ebnf$3", "symbols": ["action$ebnf$3", "action$ebnf$3$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "action", "symbols": [(lexer.has("OPTIONS") ? {type: "OPTIONS"} : OPTIONS), (lexer.has("COLON") ? {type: "COLON"} : COLON), "option_stmt", "action$ebnf$3"]},
    {"name": "option_stmt", "symbols": [(lexer.has("LBRACE") ? {type: "LBRACE"} : LBRACE), "option_param"]},
    {"name": "option_param", "symbols": [(lexer.has("OPT_STRING") ? {type: "OPT_STRING"} : OPT_STRING), "option_param"]},
    {"name": "option_param", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("IDENT") ? {type: "IDENT"} : IDENT), "option_param"]},
    {"name": "option_param", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("OPT_STRING") ? {type: "OPT_STRING"} : OPT_STRING), "option_param"]},
    {"name": "option_param$subexpression$1", "symbols": [(lexer.has("_") ? {type: "_"} : _)]},
    {"name": "option_param$subexpression$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "option_param", "symbols": ["option_param$subexpression$1", "option_param"]},
    {"name": "option_param", "symbols": [(lexer.has("RBRACE") ? {type: "RBRACE"} : RBRACE)]},
    {"name": "exp$ebnf$1", "symbols": []},
    {"name": "exp$ebnf$1$subexpression$1", "symbols": [(lexer.has("OR") ? {type: "OR"} : OR), "term"]},
    {"name": "exp$ebnf$1", "symbols": ["exp$ebnf$1", "exp$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "exp", "symbols": ["term", "exp$ebnf$1"]},
    {"name": "term$ebnf$1", "symbols": []},
    {"name": "term$ebnf$1$subexpression$1", "symbols": [(lexer.has("AND") ? {type: "AND"} : AND), "factor"]},
    {"name": "term$ebnf$1", "symbols": ["term$ebnf$1", "term$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "term", "symbols": ["factor", "term$ebnf$1"]},
    {"name": "factor", "symbols": [(lexer.has("IDENT") ? {type: "IDENT"} : IDENT)]},
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
