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
    var regex = /"([\s\S]*)=([a-z\?, '_A-Z0-9]*)"/;
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
    OPT_STRING:  {match: /"[\w:\.]+=[a-z\?\., '_A-Z0-9]+"/, value: optString},
    PROMPT_STRING:  {match: /\[\[[\w:\.]*=(?:[\s\S](?!\]\]))+\s\]\]/, value: string},
    LPAREN:  {match: /\(\s?/, value: trim},
    RPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  {match: /\{\s*/, value: trim},
    RBRACE:  {match: /\}[ \t]?/, value: trim},
    TERMINAL: {match: /terminal\s?/, value: trim},
    PLAYER: {match: /player\s?/, value: trim},
    COLON: {match: /\:\s?/, value: trim},
    KEYWORD: {match: [/next\s?/, /clear\s?/, /notext\s?/, /goto\s?/, /setlocal\s?/, /prompt\s?/, /text\s?/, /set\s?/,], value:trim},
    OPTIONS: {match: [/options\s?/], value: trim},
    WHEN: {match: /when\s?/, value: trim},
    NOT: [/not[\s\t]?/],
    AND: [/and[\s\t]?/],
    SHORT: [/short[\s\t]?/],
    OR: [/or\s?/],
    NL:  { match: /\r?\n/, lineBreaks: true },
    IDENT: { match: /[a-z_A-Z0-9]+\s*/, value: trim},
    INSTRUCTION: ['notext']
});
%}
@lexer lexer

main            -> (stmt | exp):*
stmt            -> %TERMINAL %WHEN exp termblock
                | %PLAYER %WHEN exp termblock
#Terminal block

termblock       -> %LBRACE termstmt %RBRACE %NL:+
termstmt        -> action (action):*
action          -> %KEYWORD
                | %KEYWORD %COLON %IDENT
                | %KEYWORD %COLON %PROMPT_STRING (%NL | %_):*
                | %KEYWORD %COLON %OPT_STRING (%NL | %_):*
                | %OPTIONS %COLON %LBRACE options_stmt:+ %RBRACE (%NL | %_):*

#Options statement
options_stmt    -> def_opt options_conf:*
                | %EMPTY_STRING  options_conf:*
options_conf    -> short_opt
                | kyw_opt
def_opt         -> %OPT_STRING  %_:*
short_opt       -> %SHORT %COLON %OPT_STRING %_:*
kyw_opt         -> %KEYWORD %COLON %IDENT %_:*
# Logical operators with precedence
exp             -> term (%OR term):*
term            -> factor (%AND factor):*
factor          -> %IDENT
factor          -> %NOT factor
factor          -> %LPAREN exp %RPAREN
####################################