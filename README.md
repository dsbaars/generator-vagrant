# generator-vagrant-yeoman [![Build Status](https://secure.travis-ci.org/dsbaars/generator-vagrant-yeoman.png?branch=master)](https://travis-ci.org/dsbaars/generator-vagrant-yeoman)

I created this generator because I work a lot with Vagrant, with different providers and different provisioners.

## Targets

I would like to accomplish that this generator generates a Vagrant-file for the following characteristics:

* Providers
  * VirtualBox
  * Parallels
  * Amazon EC2
  * Google Compute Engine
  * DigitalOcean
* Provisioners
  * Chef (Berkshelf)
  * Puppet (Apply)
  * Puppet (Server, especially the foreman)
* Operating systems
  * Ubuntu 14.04
  * CoreOS

### Usage

To install generator-vagrant from npm, run:

```bash
npm install -g generator-vagrant
```

Finally, initiate the generator:

```bash
yo vagrant
```

## License

MIT
