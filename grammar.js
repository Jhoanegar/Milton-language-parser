// Generated automatically by nearley, version 2.19.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }

debugger;
const fs = require('fs');
const stringsArray = fs.readFileSync('./locales/es.txt').toString().split(/\r?\n/);
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
        let keys = Object.keys(data[1]);
        keys.forEach(key=> {
            data[1][key] = false;
        })
        output = data[1];
    } else if (data.length == 1 && data[0].type == 'IDENT') {
        output[data[0].value] = true;
    } else if (data[0].type == 'LPAREN' && data[2] && data[2].type == 'RPAREN'){
        output = data[1]
    } else if (data.length == 2 && data[1].length >= 1) {
        data[1].forEach(operand => {
            if (operand[0].type == 'AND') {
                output = _.merge(data[0], operand[1]);
            } else if (operand[0].type == 'OR') {
                output = {$or: _.merge(data[0], operand[1])}
            }
        })
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
    debugger;
    if (data[0].type == 'KEYWORD') {
        switch (data[0].value) {
            case 'notext':
                output['notext'] = true;
                break;
            case 'setlocal':
            case 'set':
            case 'goto':
            case 'next':
                output.operations = [{[data[0].value]: data[2].value}];
                break;
            case 'clear':
                output.operations = [{[data[0].value]: data[2].value}];
                break;
            case 'text':
            case 'prompt':
                output[data[0].value] = strings[data[2].value.name.replace('TTRS:', '')];

                if (data[3]) {
                    output = _.merge(output, data[3]);
                }
            break;
            default:
                throw new Error(`termstmt ${JSON.stringify(data[0])} not implemented yet`)
        }
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        data[1][data[0].value] = true;
        output = data[1];
    } else if (data[0].type == 'OPTIONS' && data[1] && data[1].type == 'COLON' && data[2] && Array.isArray(data[2].options)) {
        output = data[2];
    } else if (data[0].type == 'RBRACE') {
        // do nothing
    } else if (data[0].type == 'LBRACE' || (data[0][0] && (data[0][0].type == 'NL' || data[0][0].type === '_'))) {
        output = data[1];
    }
    if (data[0].type == 'KEYWORD' && data[1].type == 'COLON' && data[2].type == 'IDENT' && data[3]) {
        if (data[3].operations && data[3].operations.length >= 1) {
            output.operations = _.concat(output.operations, data[3].operations);
            delete data[3].operations;
        }
        output = _.merge(output, data[3]);
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        output.operations = _.concat(output.operations, data[1].operations);
    }

    return output;
}

const options = data => {
    let output = {};
    //console.log(JSON.stringify(data, null, 3));
    if (data[0].type == 'KEYWORD') {
        switch (data[0].value) {
            case 'notext':
                output['notext'] = true;
                break;
            case 'setlocal':
            case 'set':
            case 'goto':
            case 'next':
            case 'clear':
                output.operations = [{[data[0].value]: data[2].value}];
                if (data[3]) {
                    output = _.merge(output, data[3]);
                }
                break;
            case 'prompt':
            case 'text':
            case 'short':
                output[data[0].value] = strings[data[2].value.name.replace('TTRS:', '')];
                if (!output[data[0].value]) {
                    throw new Error("String not found " + JSON.stringify(data[2], null , 3))
                }
                if (data[3]) {
                    output = _.merge(output, data[3]);
                }
            break;
            default:
                throw new Error(`Option ${JSON.stringify(data[0])} not implemented yet`)
        }
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        data[1][data[0].value] = true;
        output = data[1];
    } else if (data[0].type == 'OPT_STRING') {
        let prompt = { text: strings[data[0].value.name.replace('TTRS:', '')] };
        if (!prompt.text) {
            prompt.text = data[0].text;
        }
        if (!prompt.text) {
            throw new Error("Undefined string " + data[0]);
        }
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
    if (data[0].type == 'KEYWORD' && data[1].type == 'COLON' && data[2].type == 'IDENT' && data[3] && data[3].operations && data[3].operations.length > 0) {
        output.operations = _.concat(output.operations, data[3].operations);
        output = _.merge(output, data[3]);
    } else if (data[0].type == 'KEYWORD' && data[1] && !data[1].type) {
        output.operations = _.concat(output.operations, data[1].operations);
        output = _.merge(output, data[1]);
    }
    return output;
}

const reject = data => {
    return null;
}
var grammar = {
    Lexer: lexer,
    ParserRules: [
    {"name": "main$ebnf$1", "symbols": []},
    {"name": "main$ebnf$1$subexpression$1", "symbols": ["stmt"]},
    {"name": "main$ebnf$1$subexpression$1", "symbols": ["exp"]},
    {"name": "main$ebnf$1", "symbols": ["main$ebnf$1", "main$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "main", "symbols": ["main$ebnf$1"], "postprocess": stmt},
    {"name": "stmt", "symbols": [(lexer.has("TERMINAL") ? {type: "TERMINAL"} : TERMINAL), (lexer.has("WHEN") ? {type: "WHEN"} : WHEN), "exp", "termblock"], "postprocess": stmt},
    {"name": "stmt", "symbols": [(lexer.has("PLAYER") ? {type: "PLAYER"} : PLAYER), (lexer.has("WHEN") ? {type: "WHEN"} : WHEN), "exp", "termblock"], "postprocess": stmt},
    {"name": "termblock", "symbols": [(lexer.has("LBRACE") ? {type: "LBRACE"} : LBRACE), "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("IDENT") ? {type: "IDENT"} : IDENT), "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("PROMPT_STRING") ? {type: "PROMPT_STRING"} : PROMPT_STRING), "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("OPT_STRING") ? {type: "OPT_STRING"} : OPT_STRING), "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("INTER_STRING") ? {type: "INTER_STRING"} : INTER_STRING), "option_param"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("OPTIONS") ? {type: "OPTIONS"} : OPTIONS), (lexer.has("COLON") ? {type: "COLON"} : COLON), "option_stmt", "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("IDENT") ? {type: "IDENT"} : IDENT), "termstmt"], "postprocess": termstmt},
    {"name": "termstmt$subexpression$1", "symbols": [(lexer.has("_") ? {type: "_"} : _)]},
    {"name": "termstmt$subexpression$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "termstmt", "symbols": ["termstmt$subexpression$1", "termstmt"], "postprocess": termstmt},
    {"name": "termstmt", "symbols": [(lexer.has("RBRACE") ? {type: "RBRACE"} : RBRACE)], "postprocess": termstmt},
    {"name": "option_stmt", "symbols": [(lexer.has("LBRACE") ? {type: "LBRACE"} : LBRACE), "option_param"], "postprocess": options},
    {"name": "option_param", "symbols": [(lexer.has("OPT_STRING") ? {type: "OPT_STRING"} : OPT_STRING), "option_param"], "postprocess": options},
    {"name": "option_param", "symbols": [(lexer.has("PROMPT_STRING") ? {type: "PROMPT_STRING"} : PROMPT_STRING), "option_param"], "postprocess": options},
    {"name": "option_param", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("IDENT") ? {type: "IDENT"} : IDENT), "option_param"], "postprocess": options},
    {"name": "option_param", "symbols": [(lexer.has("KEYWORD") ? {type: "KEYWORD"} : KEYWORD), (lexer.has("COLON") ? {type: "COLON"} : COLON), (lexer.has("OPT_STRING") ? {type: "OPT_STRING"} : OPT_STRING), "option_param"], "postprocess": options},
    {"name": "option_param$subexpression$1", "symbols": [(lexer.has("_") ? {type: "_"} : _)]},
    {"name": "option_param$subexpression$1", "symbols": [(lexer.has("NL") ? {type: "NL"} : NL)]},
    {"name": "option_param", "symbols": ["option_param$subexpression$1", "option_param"], "postprocess": options},
    {"name": "option_param", "symbols": [(lexer.has("RBRACE") ? {type: "RBRACE"} : RBRACE)], "postprocess": options},
    {"name": "exp$ebnf$1", "symbols": []},
    {"name": "exp$ebnf$1$subexpression$1", "symbols": [(lexer.has("OR") ? {type: "OR"} : OR), "term"]},
    {"name": "exp$ebnf$1", "symbols": ["exp$ebnf$1", "exp$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "exp", "symbols": ["term", "exp$ebnf$1"], "postprocess": ident},
    {"name": "term$ebnf$1", "symbols": []},
    {"name": "term$ebnf$1$subexpression$1", "symbols": [(lexer.has("AND") ? {type: "AND"} : AND), "factor"]},
    {"name": "term$ebnf$1", "symbols": ["term$ebnf$1", "term$ebnf$1$subexpression$1"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "term", "symbols": ["factor", "term$ebnf$1"], "postprocess": ident},
    {"name": "factor", "symbols": [(lexer.has("NOT") ? {type: "NOT"} : NOT), "factor"], "postprocess": ident},
    {"name": "factor", "symbols": [(lexer.has("LPAREN") ? {type: "LPAREN"} : LPAREN), "exp", (lexer.has("RPAREN") ? {type: "RPAREN"} : RPAREN)], "postprocess": ident},
    {"name": "factor", "symbols": [(lexer.has("IDENT") ? {type: "IDENT"} : IDENT)], "postprocess": ident}
]
  , ParserStart: "main"
}
if (typeof module !== 'undefined'&& typeof module.exports !== 'undefined') {
   module.exports = grammar;
} else {
   window.grammar = grammar;
}
})();
