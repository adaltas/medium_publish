
readline = require 'readline'
  
module.exports = (question) ->
  new Promise (resolve) ->
    rl = readline.createInterface
      input: process.stdin
      output: process.stdout
    rl.question "#{question}: ", (answer) ->
      rl.close()
      resolve answer
