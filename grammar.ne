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
%}
@lexer lexer

main            -> exp
# Logical operators with precedence
exp             -> term (%OR term):*
term            -> factor (%AND factor):*
factor          -> %VARIABLE_NAME
factor          -> %NOT factor
factor          -> %LPAREN exp %RPAREN
####################################
# main                -> statement
# statement           -> null
#                         | %KEYWORD %_ expression
#                         | %KEYWORD %_ statement %_:* expression
# expression           -> %VARIABLENAME {% data => variables[data] ? variables[data] : variables[data] = false %}
#                         | %NOT %_ expression
#                         | expression %_ %LOGICAL_BINARY %_ expression
#                         | %LBRACE %_:* statement %_:* %RBRACE
# |                           | %LPAREN %_:* expression %_:* %RPAREN
                        
     