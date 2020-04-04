
@{%
debugger;
global.variables = require('./src/configuration')['QueryMLA.dlg'];
const _ = require('lodash');
const moo = require("moo");
const trim = token => {
    console.log(`"${token}"`)
    return token.trim()
};
const string = token => {
    var regex = /\[\[(?:[\w:\.]*=(?:[\s\S](?!\]\]))+[\S\s]| )\]\]\s*/ // Same regexp but with a capture group
    let match = token.match(regex)
    console.log(match)
    return {string: match[2], name: match[1]};
}
const optString = token => {
    var regex = /"([\s\S]*)=?([a-z%\[\]\?\!,#:@\+=\-\(\)\/ '\*_A-Z0-9]+)"/;
    let match = token.match(regex);
    console.log(match)
    if (match && match[1] && match[2]) {
        return {string: match[2], name: match[1]}
    } else {
        return {string: ' ', name: ' '}
    }
}
const interString = token => {
    var regex = /".*\$(\(.*\)).*"/;
    let match = token.match(regex);
    console.log(match)
    if (match && match[1]) {
        return {name: match[1], token: token}
    } else {
        return {string: ' ', name: ' '}
    }
}
const lexer = moo.compile({
    _:      /[ \t]+/,
    NUMBER:  /0|[1-9][0-9]*/,
    //EMPTY_STRING: /" " /,
    OPT_STRING:  {match: /"[\w:\.]*=?[a-z%\[\]\?\!\.,#:@\+=\-\(\)\/ \*'_A-Z0-9]*"/, value: optString},
    PROMPT_STRING:  {match: /\[\[(?:[\w:\.]*=(?:[\s\S](?!\]\]))+[\S\s]| )\]\]\s*/, value: string},
    LPAREN:  {match: /\(\s?/, value: trim},
    RPAREN:  {match: /\)\s?/, value: trim},
    LBRACE:  {match: /\{\s*/, value: trim},
    RBRACE:  {match: /\}\s*/, value: trim},
    TERMINAL: {match: /terminal\s?/, value: trim},
    PLAYER: {match: /player\s?/, value: trim},
    COLON: {match: /\:\s*/, value: trim},
    KEYWORD: {match: [/autonext\s?/, /short\s?/, /next\s?/, /clear\s?/, /notext\s?/, /goto\s?/, /setlocal\s?/, /prompt\s?/, /text\s?/, /set\s?/,], value:trim},
    OPTIONS: {match: [/options\s?/], value: trim},
    WHEN: {match: /when\s?/, value: trim},
    NOT: [/not[\s\t]?/],
    AND: [/and[\s\t]+/],
    OR: [/or\s?/],
    NL:  { match: /\r?\n/, lineBreaks: true },
    IDENT: { match: /[a-z_A-Z0-9]+\s*/, value: trim},
    INTER_STRING: { match: /".*\$\(.*\).*"/, value: interString}
});

const ident = (data) => {
    let output;
    if (data[0].type == 'NOT') {
        output = !data[1].value;
    }
    else if (data.length == 1) {
        output = variables[data[0].value] ? true : false;
    } else if (data[0].type == 'LPAREN' && data[2] && data[2].type == 'RPAREN'){
        output = data[1]
    }
    return output;
}
const and = data => {
    let lhs = data[0];
    let output;
    if (data[1].length == 0) {
        output = data[0]
    } else if (data[1][0].length == 2) {
        if (data[1][0][0].type == 'AND') {
            output = lhs && data[1][0][1];
        }
    }
    return output;
}
const or = data => {
    let lhs = data[0];
    let rhs;
    let output;
    if (data[1].length == 2) {
        if (data[1].type == 'OR') {
            output = lhs || rhs;
        }
    } else if (data[1].length == 0) {
        output = data[0]
    }
    return output;
}

const stmt = data => {
    debugger;
    return data;
}
const termstmt = data => {
    debugger;
    let output = {};
    if (data.length >= 3 &&
        data[0].type == 'KEYWORD' &&
        data[1].type == 'COLON' &&
        data[2].type == 'IDENT') {
        switch (data[0].value) {
            case 'notext':
                output['notext'] = true;
                break;
            case 'setlocal':
            case 'set':
            case 'goto':
                output[data[0].value] = data[2].value;
                variables[data[2].value] = true;
                break;
            case 'clear':
                output[data[0].value] = data[2].value;
                variables[data[2].value] = false;
                break;
        }
    } else if (data[0].type == 'KEYWORD' && !data[1].type) {
        data[1][data[0].value] = true;
        output = data[1];
    } else if (data[0].type == 'RBRACE') {
        // do nothing
    } else if (data[0].type == 'LBRACE') {
        output = data[1];
    }
    if (data && data[3] && Object.keys(data[3]).length > 0) {
        output = _.merge(output, data[3]);
    }
    return output;
}

const reject = data => {
    debugger;
    return null;
}
%}
@lexer lexer

main            -> (stmt | exp):*
stmt            -> %TERMINAL %WHEN exp termblock
                | %PLAYER %WHEN exp termblock                       {% stmt %}
#Terminal block

termblock       -> %LBRACE termstmt                                 {% termstmt %}
termstmt        ->
                  %KEYWORD %COLON %IDENT termstmt                   {% termstmt %}
                | %KEYWORD %COLON %PROMPT_STRING termstmt           {% termstmt %}
                | %KEYWORD %COLON %OPT_STRING termstmt              {% termstmt %}
                | %KEYWORD %COLON %INTER_STRING option_param        {% termstmt %}
                | %OPTIONS %COLON option_stmt termstmt              {% termstmt %}
                | %KEYWORD termstmt                                 {% termstmt %}
                | %IDENT termstmt                                   {% termstmt %}
                | (%_ | %NL) termstmt                               {% reject %}
                | %RBRACE                                           {% termstmt %}

#Options statement
option_stmt    -> %LBRACE option_param 
option_param   -> %OPT_STRING option_param
                | %PROMPT_STRING option_param
                | %KEYWORD %COLON %IDENT option_param
                | %KEYWORD %COLON %OPT_STRING option_param
                | (%_ | %NL) option_param
                | %RBRACE

# Logical operators with precedence
exp             -> term (%OR term):*                {% or %}
term            -> factor (%AND factor):*           {% and %}
factor          -> %NOT factor                      {% ident %}
factor          -> %LPAREN exp %RPAREN              {% ident %}
factor          -> %IDENT                           {% ident %}

####################################