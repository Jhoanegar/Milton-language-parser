const { prompt, AutoComplete } = require('enquirer');

const ask = new AutoComplete({
  name: "LOLO",
  message: '>>',
  choices:  [
    {
       "message": "asdfa",
       "value": {
          "next": "Nonsense_QueryMLA"
       }
    },
    {
       "message": "listado",
       "value": {
          "next": "MoreSpecific"
       }
    },
    {
       "message": "ayuda",
       "value": {
          "next": "MoreSpecific"
       }
    },
    {
       "message": "¿Entiendes lo que estoy diciendo?",
       "value": {
          "next": "Understand_QueryMLA"
       }
    },
    {
       "message": "Salir",
       "value": {
          "clear": "QueryMLA_ON",
          "next": "CLI_Resume"
       }
    }
  ]})

  ask.run()


 