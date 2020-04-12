class Option {
    constructor({text, operations}) {
        if (!text) {
            throw new Error("Expected text");
        }
        if (!operations) {
            this._operations = [];
        }
        this._text = text;
        this._operations = operations;
    }

    set text(text) {
        this._text = text;
    }
    get text() {
        return this._text
    }
    set operations(operations) {
        this._operations = operations;
    }
    get operations() {
        return this._operations;
    }

    toAutoComplete() {
        return {name: this._text};
    }

    toString() {
        return JSON.stringify({text: this._text, operations: this._operations}, null, 3);
    }
}

module.exports = Option;