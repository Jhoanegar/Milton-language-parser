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
    var regex = /\[\[([\w:\.]+)=([\s\S](?!\]\]))+ ?\]\]/ // Same regexp but with a capture group
    let match = token.match(regex)
    return {string: match[2], name: match[1]};
}
const optString = token => {
    var regex = /"([\s\S]*)=([a-z '_A-Z0-9]*)"/;
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
    EMPTY_STRING: /" "/,
    OPT_STRING:  {match: /"[\w:\.]+=[a-z '_A-Z0-9]+"/, value: optString},
    PROMPT_STRING:  {match: /\[\[[\w:\.]+=(?:[\s\S](?!\]\]))+ ?\]\]/, value: string},
    LPAREN:  {match: /\(/, value: trim},
    RPAREN:  {match: /\)/, value: trim},
    LBRACE:  {match: /\{/, value: trim},
    RBRACE:  {match: /\}[ \t]?/, value: trim},
    TERMINAL: {match: /terminal/, value: trim},
    COLON: {match: /\:/, value: trim},
    KEYWORD: {match: [/notext/, /goto/, /setlocal/, /prompt/], value:trim},
    OPTIONS: {match: [/options/], value: trim},
    WHEN: {match: /when/, value: trim},
    NOT: [/not/],
    AND: [/and/],
    SHORT: [/short/],
    NEXT: [/next/],
    SET: [/set/],
    OR: [/or/],
    NL:      { match: /\n/, lineBreaks: true },
    IDENT: { match: /[a-z_A-Z0-9]+/, value: trim},
    INSTRUCTION: ['notext']
});
%}
@lexer lexer

main            -> (stmt | exp | %NL | %_):*
stmt            -> %TERMINAL %_ %WHEN %_ exp termblock
#Terminal block

termblock       -> %LBRACE (%_ | %NL):+ termstmt (%_ | %NL):+ %RBRACE %NL:+
termstmt        -> action (%_ | %NL):* (action):* 
action          -> %KEYWORD
                | %KEYWORD %COLON %_ %IDENT (%_ | %NL):*
                | %KEYWORD %COLON %_ %PROMPT_STRING (%NL | %_):+
                | set_opt (%NL | %_):*
                | %OPTIONS %COLON (%_):* %LBRACE (%NL | %_):* options_stmt:+ %RBRACE (%NL | %_):*

#Options statement
options_stmt    -> def_opt options_conf:*
                | %EMPTY_STRING %_ options_conf:*
options_conf    -> short_opt (%NL):*
                | next_opt (%NL):*
                | set_opt (%NL):*
def_opt         -> %OPT_STRING  %_:*
short_opt       -> %SHORT %COLON %_:* %OPT_STRING %_:*
next_opt        -> %NEXT %COLON %_:* %IDENT %_:*
set_opt        -> %SET %COLON %_:* %IDENT %_:*
# Logical operators with precedence
exp             -> term (%OR (%_ | %NL):+ term):*
term            -> factor (%AND (%_ | %NL):+ factor):*
factor          -> %IDENT (%_ | %NL):*
factor          -> %NOT (%_ | %NL):+ factor
factor          -> %LPAREN exp %RPAREN (%_ | %NL):*
####################################