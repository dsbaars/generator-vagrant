"use strict"
util = require("util")
path = require("path")
yeoman = require("yeoman-generator")
yosay = require("yosay")
yaml = require('js-yaml')
fs   = require('fs')

VagrantYeomanGenerator = yeoman.generators.Base.extend(
    initializing: ->
        @pkg = require("../package.json")
        return

    prompting: ->
        done = @async()

        capacities = yaml.safeLoad(fs.readFileSync('data/capacities.yml', 'utf8'))

        prompts = [
            {
                type: "confirm"
                name: "doVagrantUp"
                message: "Do you want to execute vagrant up after generation?"
                default: true
            },
            {
                type: "list"
                name: "capacity"
                message: 'What capacity do you want?'
                choices: capacities
            }
            ]


        @prompt prompts, ((props) ->
            @doVagrantUp = props.doVagrantUp
            done()
            return
        ).bind(this)

        return

    writing:
        app: ->
            @dest.mkdir "app"
            @dest.mkdir "app/templates"
            @src.copy "_package.json", "package.json"
            @src.copy "_bower.json", "bower.json"
            return

    end: ->
        @installDependencies()
        return
)
module.exports = VagrantYeomanGenerator
