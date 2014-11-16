"use strict"
require 'shelljs/global'
util = require("util")
path = require("path")
yeoman = require("yeoman-generator")
yosay = require("yosay")
yaml = require('js-yaml')
split = require('split')
fs   = require('fs')
_ = require('lodash')
chalk = require('chalk')
logError = chalk.bold.red
logSuccess = chalk.bold.orange

VagrantYeomanGenerator = yeoman.generators.Base.extend(
    initializing: ->
        @providers = yaml.load(fs.readFileSync(__dirname + '/data/providers.yaml', 'utf8'))
        # No safeloading since the box names otherwise do not work
        @provisioners = yaml.load(fs.readFileSync(__dirname + '/data/provisioners.yaml', 'utf8'))

        return

    prompting: ->
        done = @async()

        capacities = yaml.safeLoad(fs.readFileSync(__dirname + '/data/capacities.yaml', 'utf8'))

        capacity_names = _.transform(capacities, ((res, val, key) ->
            if val.cpus and val.memory
                res.push({value: key, name: key + " - vCPUs: " + val.cpus + " - vMemory: " + val.memory })
                return res
            else
                return false
            ), [])

        prompts = [
            {
                type: 'input'
                name: 'hostname'
                message: 'What is the hostname?'
                default: 'development'
            }
            {
                type: "list"
                name: "provider"
                message: 'What provider do you want to use?'
                choices: ((answers) =>
                    _.transform(@providers.providers, ((res, val, key) ->
                        res.push({value: key, name: key })
                        ), [])
                    )
                default: if process.env['VAGRANT_DEFAULT_PROVIDER']? then process.env['VAGRANT_DEFAULT_PROVIDER'] else null
            },
            {
                type: "list"
                name: "box"
                message: 'What box do you want to use?'
                choices: ((answers) ->
                    boxes = yaml.load(fs.readFileSync(__dirname + '/data/boxes.yaml', 'utf8'))

                    _.transform(boxes[answers.provider], ((res, val, key) ->
                        if val.name
                            res.push({value: val.name, name: val.name })

                            return res
                        else
                            return false
                        ), [])

                    )
            },
            {
                type: "list"
                name: "capacity"
                message: 'What capacity do you want?'
                choices: capacity_names
            },
            {
                type: "list"
                name: "provisioner"
                message: 'What provisioner do you want to use?'
                choices: @provisioners.provisioners
            },
            {
                type: "confirm"
                name: "doVagrantUp"
                message: "Do you want to execute vagrant up after generation?"
                default: false
            }
            {
                type: "confirm"
                name: "doInstallPlugins"
                message: "Do you want me to install plugins when they are missing?"
                default: false
            }
            ]


        @prompt prompts, ((props) ->
            @doVagrantUp = props.doVagrantUp
            @doInstallPlugins = props.doInstallPlugins

            console.log(props.box)

            @vm = {
                box: props.box
                hostname: props.hostname
                vMemory: capacities[props.capacity].memory
                vCpu: capacities[props.capacity].cpus
            }

            @settings = {
                provider: props.provider
                provisioner: props.provisioner
            }

            done()
            return
        ).bind(this)

        return

    writing:
        app: ->
            @template "Vagrantfile", "Vagrantfile"
            return

    install: ->
        output = exec('vagrant plugin list', {silent:true}).output

        if @providers.providers[@settings.provider]? and @providers.providers[@settings.provider].plugins?
            _.each(@providers.providers[@settings.provider].plugins, (val) =>
                if not output.match(val)
                    console.log(logError('The plugin %s is missing!'), val)
                    if @doInstallPlugins
                        @spawnCommand('vagrant', ['plugin', 'install', val])
            )

        if @provisioners[@settings.provisioner]?
            if @provisioners[@settings.provisioner].plugins?
                _.each(@provisioners[@settings.provisioner].plugins, (val) =>
                    if not output.match(val)
                        console.log(logError('The plugin %s is missing!'), val)
                        if @doInstallPlugins
                            @spawnCommand('vagrant', ['plugin', 'install', val])
                    # else
                    #     console.log(logSuccess('The plugin %s is available'), val)

                    return
                )

            if @provisioners[@settings.provisioner].commands?
                _.each(@provisioners[@settings.provisioner].commands, (val) =>
                    console.log(chalk.bold.yellow('Executing %s'), val)
                    exec(val)
                )


        return

    end: ->
        if @doVagrantUp
            @spawnCommand('vagrant', ['up'])
        return
)
module.exports = VagrantYeomanGenerator
