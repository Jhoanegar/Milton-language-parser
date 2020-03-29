#Terminal: Single constant, string or token
# if


#nonterminal: Set of possible strings

#rule/production rule: i
#  ifStatement -> "if" condition "then" statement "endif"

#@builtin "number.ne"
#@builtin "string.ne" 
@{%
let variables = {};
const moo = require("moo");
const trim = token => {token.trim()};
const string = token => {
    var regex = /\[\[([\w:\.])*=([\s\S](?!\]\]))+\s\]\]/ // Same regexp but with a capture group
    let match = token.match(regex)
    return {string: match[2], name: match[1]};
}
const optString = token => {
    var regex = /"([\s\S]+)=([a-z _A-Z0-9]+)"/;
    let match = token.match(regex);
    return {string: match[2], name: match[1]}
}
const lexer = moo.compile({
    _:      /[ \t]+/,
    NUMBER:  /0|[1-9][0-9]*/,
    OPT_STRING:  {match: /"[\w:\.]+=[a-z _A-Z0-9]+"/, value: optString},
    PROMPT_STRING:  {match: /\[\[[\w:\.]*=(?:[\s\S](?!\]\]))+\s\]\]/, value: string},
    LPAREN:  {match: /\(\s?/, value: trim},
    RPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  {match: /\{\s?/, value: trim},
    RBRACE:  {match: /\}[ \t]?/, value: trim},
    TERMINAL: {match: /terminal\s?/, value: trim},
    COLON: {match: /\:\s?/, value: trim},
    KEYWORD: {match: [/notext\s?/, /goto\s?/, /setlocal\s?/, /prompt\s?/], value:trim},
    OPTIONS: {match: [/options\s?/], value: trim},
    WHEN: {match: /when\s?/, value: trim},
    NOT: [/not[\s\t]?/],
    AND: [/and[\s\t]?/],
    SHORT: [/short[\s\t]?/],
    NEXT: [/next[\s\t]?/],
    SET: [/set[\s\t]?/],
    OR: [/or\s?/],
    NL:      { match: /\n/, lineBreaks: true },
    IDENT: { match: /[a-z_A-Z0-9]+\s?/, value: trim},
    INSTRUCTION: ['notext']
});
%}
@lexer lexer

main            -> (stmt | exp):*
stmt            -> %TERMINAL %WHEN exp termblock
#Terminal block

termblock       -> %LBRACE termstmt %RBRACE %NL:+
termstmt        -> action (action):*
action          -> %KEYWORD
                | %KEYWORD %COLON %IDENT
                | %KEYWORD %COLON %PROMPT_STRING (%NL | %_):+
                | %OPTIONS %COLON %LBRACE options_stmt:+ %RBRACE (%NL | %_):*

#Options statement
options_stmt    -> def_opt %_ (short_opt %_):* next_opt %_:* ( set_opt (%NL | %_):*):*
def_opt         -> %OPT_STRING
short_opt       -> %SHORT %COLON %OPT_STRING
next_opt        -> %NEXT %COLON %IDENT
set_opt        -> %SET %COLON %IDENT
# Logical operators with precedence
exp             -> term (%OR term):*
term            -> factor (%AND factor):*
factor          -> %IDENT
factor          -> %NOT factor
factor          -> %LPAREN exp %RPAREN
####################################