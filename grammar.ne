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
const trim = token => {
    console.log(`"${token}"`)
    return token.trim()
};
const string = token => {
    var regex = /\[\[([\w:\.])*=?([\s\S](?!\]\]))+\s\]\]/ // Same regexp but with a capture group
    let match = token.match(regex)
    console.log(match)
    return {string: match[2], name: match[1]};
}
const optString = token => {
    var regex = /"([\s\S]*)=*([a-z%\[\]\?,: '\*_A-Z0-9]+)"/;
    let match = token.match(regex);
    console.log(match)
    if (match && match[1] && match[2]) {
        return {string: match[2], name: match[1]}
    } else {
        return {string: ' ', name: ' '}
    }
}
const lexer = moo.compile({
    _:      /[ \t]+/,
    NUMBER:  /0|[1-9][0-9]*/,
    //EMPTY_STRING: /" " /,
    OPT_STRING:  {match: /"[\w:\.]*=?[a-z%\[\]\?\.,: \*'_A-Z0-9]*"/, value: optString},
    PROMPT_STRING:  {match: /\[\[[\w:\.]*=(?:[\s\S](?!\]\]))+\s\]\]/, value: string},
    LPAREN:  {match: /\(\s?/, value: trim},
    RPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  {match: /\{\s*/, value: trim},
    RBRACE:  {match: /\}\s*/, value: trim},
    TERMINAL: {match: /terminal\s?/, value: trim},
    PLAYER: {match: /player\s?/, value: trim},
    COLON: {match: /\:\s?/, value: trim},
    KEYWORD: {match: [/short\s?/, /next\s?/, /clear\s?/, /notext\s?/, /goto\s?/, /setlocal\s?/, /prompt\s?/, /text\s?/, /set\s?/,], value:trim},
    OPTIONS: {match: [/options\s?/], value: trim},
    WHEN: {match: /when\s?/, value: trim},
    NOT: [/not[\s\t]?/],
    AND: [/and[\s\t]+/],
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

termblock       -> %LBRACE termstmt
termstmt        -> %KEYWORD termstmt
                | %KEYWORD %COLON %IDENT termstmt
                | %KEYWORD %COLON %PROMPT_STRING termstmt
                | %KEYWORD %COLON %OPT_STRING termstmt
                | %OPTIONS %COLON option_stmt termstmt
                | (%_ | %NL) termstmt
                | %RBRACE

#Options statement
option_stmt    -> %LBRACE option_param 
option_param   -> %OPT_STRING option_param
                | %KEYWORD %COLON %IDENT option_param
                | %KEYWORD %COLON %OPT_STRING option_param
                | (%_ | %NL) option_param
                | %RBRACE

# Logical operators with precedence
exp             -> term (%OR term):*
term            -> factor (%AND factor):*
factor          -> %IDENT
factor          -> %NOT factor
factor          -> %LPAREN exp %RPAREN
####################################