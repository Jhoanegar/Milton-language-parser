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
const lexer = moo.compile({
    _:      /[ \t]+/,
    NUMBER:  /0|[1-9][0-9]*/,
    STRING:  /"(?:\\["\\]|[^\n"\\])*"/,
    LPAREN:  {match: /\(\s?/, value: trim},
    RPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  {match: /\{\s?/, value: trim},
    RBRACE:  {match: /\}[ \t]?/, value: trim},
    TERMINAL: {match: /terminal\s?/, value: trim},
    COLON: {match: /\:\s?/, value: trim},
    KEYWORD: {match: [/notext\s?/, /goto\s?/, /setlocal\s?/], value:trim},
    WHEN: {match: /when\s?/, value: trim},
    NOT: [/not[\s\t]?/],
    AND: [/and[\s\t]?/],
    OR: [/or\s?/],
    NL:      { match: /\n/, lineBreaks: true },
    VARIABLE_NAME: { match: /[A-Z][a-z_A-Z0-9]+\s?/, value: trim},
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
                | %KEYWORD %COLON %VARIABLE_NAME

# Logical operators with precedence
exp             -> term (%OR term):*
term            -> factor (%AND factor):*
factor          -> %VARIABLE_NAME
factor          -> %NOT factor
factor          -> %LPAREN exp %RPAREN
####################################