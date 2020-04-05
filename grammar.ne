
@{%
debugger;
const fs = require('fs');
const stringsArray = fs.readFileSync('./locales/es.txt').toString().split(/\r\n/);
const strings = {};
stringsArray.forEach(string => {
    let match = string.match(/([^=]+)=(.*)/)
    if (match && match[1] && match[2]) {
        strings[match[1]] = match[2];
    }
})
const _ = require('lodash');
const moo = require("moo");
const trim = token => {
    return token.trim()
};
const promptString = token => {
    var regex = /\[\[(?:([\w:\.]*)=((?:[\s\S](?!\]\]))+[\S\s])| )\]\]\s*/ // Same regexp but with a capture group
    let match = token.match(regex)
    console.log(match)
    return {string: match[2], name: match[1]};
}
const optString = token => {
    var regex = /"([\w:\.]*)=?([a-z%\[\]\?\!\.,#:@\+=\-\(\)\/ \*'_A-Z0-9]*)"/;
    let match = token.match(regex);
    if (match && match[1] && match[2]) {
        return {string: match[2], name: match[1]}
    } else {
        return {string: ' ', name: ' '}
    }
}
const interString = token => {
    var regex = /".*\$(\(.*\)).*"/;
    let match = token.match(regex);
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
    PROMPT_STRING:  {match: /\[\[(?:[\w:\.]*=(?:[\s\S](?!\]\]))+[\S\s]| )\]\]\s*/, value: promptString},
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
    let output = {};
    if (data[0].type == 'NOT') {
        output = {not: data[1].value};
    } else if (data.length == 1 && data[0].type == 'IDENT') {
        output[data[0].value] = true;
    } else if (data[0].type == 'LPAREN' && data[2] && data[2].type == 'RPAREN'){
        output = data[1]
    } else if (data.length == 2 && data[1].length == 1 && data[1][0][0].type == 'AND') {
        output = _.merge(data[0], data[1][0][1]);
    } else {
        output = data[0];
    }
    return output;
}

const stmt = data => {
    return [...data];
}
const termstmt = data => {
    let output = {};
    if (data[0].type == 'KEYWORD') {
        switch (data[0].value) {
            case 'notext':
                output['notext'] = true;
                break;
            case 'setlocal':
            case 'set':
            case 'goto':
            case 'next':
                output[data[0].value] = data[2].value;
                break;
            case 'clear':
                output[data[0].value] = data[2].value;
                break;
            case 'text':
            case 'prompt':
                output[data[0].value] = strings[data[2].value.name.replace('TTRS:', '')];
                if (data[3]) {
                    output = _.merge(output, data[3]);
                }
            break;
            default:
                throw new Error(`${JSON.stringify(data[0])} not implemented yet`)
        }
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        data[1][data[0].value] = true;
        output = data[1];
    } else if (data[0].type == 'OPTIONS' && data[1] && data[1].type == 'COLON' && data[2] && Array.isArray(data[2].options)) {
        output = data[2];
    } else if (data[0].type == 'RBRACE') {
        // do nothing
    } else if (data[0].type == 'LBRACE' || (data[0][0] && data[0][0].type == 'NL')) {
        output = data[1];
    }
    if (data[0].type == 'KEYWORD' && data[1].type == 'COLON' && data[2].type == 'IDENT') {
        output = _.merge(output, data[3]);
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        output = _.merge(output, data[1]);
    }

    return output;
}

const options = data => {
    let output = {};
    if (data[0].type == 'KEYWORD') {
        switch (data[0].value) {
            case 'notext':
                output['notext'] = true;
                break;
            case 'setlocal':
            case 'set':
            case 'goto':
            case 'next':
                output[data[0].value] = data[2].value;
                break;
            case 'clear':
                output[data[0].value] = data[2].value;
                break;
            case 'prompt':
            case 'text':
                output[data[0].value] = strings[data[2].value.name.replace('TTRS:', '')];
            break;
            default:
                throw new Error(`${JSON.stringify(data[0])} not implemented yet`)
        }
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        data[1][data[0].value] = true;
        output = data[1];
    } else if (data[0].type == 'OPT_STRING') {
        debugger;
        let prompt = { text: strings[data[0].value.name.replace('TTRS:', '')] };
        if (data[1].options) {
            let options = _.clone(data[1]).options;
            delete data[1].options;
            data[1].prompt = prompt;
            output = {options: [data[1],...options]};
        } else {
            data[1].prompt = prompt;
            output.options = [data[1]]
        }
    } else if (data[0].type == 'RBRACE') {
        // do nothing
    } else if (data[0].type == 'LBRACE' || (data[0][0] && (data[0][0].type == 'NL' || data[0][0].type == '_'))) {
        output = data[1];
    }
    if (data[0].type == 'KEYWORD' && data[1].type == 'COLON' && data[2].type == 'IDENT') {
        output = _.merge(output, data[3]);
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        output = _.merge(output, data[1]);
    }

    return output;
}

const reject = data => {
    return null;
}
%}
@lexer lexer

main            -> (stmt | exp):*                                   {% stmt %}
stmt            -> %TERMINAL %WHEN exp termblock                    {% stmt %}
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
                | (%_ | %NL) termstmt                               {% termstmt %}
                | %RBRACE                                           {% termstmt %}

#Options statement
option_stmt    -> %LBRACE option_param                              {% options %}
option_param   -> %OPT_STRING option_param                          {% options %}
                | %PROMPT_STRING option_param                       {% options %}
                | %KEYWORD %COLON %IDENT option_param               {% options %}
                | %KEYWORD %COLON %OPT_STRING option_param          {% options %}
                | (%_ | %NL) option_param                           {% options %}
                | %RBRACE                                           {% options %}

# Logical operators with precedence
exp             -> term (%OR term):*                                {% ident %}
term            -> factor (%AND factor):*                           {% ident %}
factor          -> %NOT factor                                      {% ident %}
factor          -> %LPAREN exp %RPAREN                              {% ident %}
factor          -> %IDENT                                           {% ident %}

####################################