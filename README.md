Journeyman
=====================
[![Gem Version](https://badge.fury.io/rb/journeyman.svg)](http://badge.fury.io/rb/journeyman) [![Code Climate](https://codeclimate.com/github/ElMassimo/journeyman/badges/gpa.svg)](https://codeclimate.com/github/ElMassimo/journeyman) [![Test Coverage](https://codeclimate.com/github/ElMassimo/journeyman/badges/coverage.svg)](https://codeclimate.com/github/ElMassimo/journeyman) [![Inline docs](http://inch-ci.org/github/ElMassimo/journeyman.svg)](http://inch-ci.org/github/ElMassimo/journeyman) [![Build Status](https://travis-ci.org/ElMassimo/journeyman.svg)](https://travis-ci.org/ElMassimo/journeyman) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/ElMassimo/journeyman/blob/master/LICENSE.txt)

Journeyman is a fixtures replacement with an extremely light definition syntax,
providing two default build strategies, but allowing full customization on how
to build an object.

## Usage
Journeyman is built to work out of the box with RSpec and Cucumber, and any
console environment, if you need support for other testing frameworks we can
work it out :smiley:.

Since it has no dependencies, it's possible to use it in any Ruby project.

### Load
Journeyman will attempt to load files under the `spec/factories` directory, but
you may overwrite `Journeyman.factories_paths` by providing an Array that
containst different paths for factories.

### Definition
Journeyman allows you to provide the default attributes for creation as the
return value of the definition block.

```ruby
Journeyman.define :album do |t|
  {
    title: 'Wish You Were Here',
    recorded_ago: -> { (Date.today - Date.new(1975, 9, 12)).round / 365 },
    band: -> { Journeyman.create(:band, name: 'Pink Floyd') }
  }
end
```
The default values are superseded by the value you provide to `build` or `create`.

```ruby
pink_floyd = find_band('Pink Floyd')

Journeyman.build(:album, band: pink_floyd) == Album.new({
  title: 'Wish You Were Here',
  recorded_ago: -> { ... }.call,
  band: pink_floyd
})
```
The default values can be static, or dynamic. If you specify a `Proc` or `lambda`
as a default value for an attribute, it will be evaluated whenever the attribute
is not provided when an object is built.

### Configuration
Journeyman is a configurable beast, yet has really strong defaults.
```ruby
# DSL Methods
find, process, ignore, build, after_create

# Configuration Options
[:parent, :model, :finder_attribute]
```

#### DSL
Journeyman provides a nice DSL that lets you provide a block or lambda with your
own builder, or finder, and other miscellanous (and handy) hooks.

* `find:` Allows you to define the finder, takes a single argument.

* `build:` You can provide a custom builder, receives a Hash of attributes, but
you have full liberty of what you do with them, the return value must be the
built object.

* `process:` If you need to process the attributes before building you can
provide a block to do just that, make sure to return the attributes at the end.

* `ignore:` There are cases where you want to ignore certain attributes during
the `build`, but you want them in the `after_create` callback. You can ignore
those attributes by passing a list, or Array with the attributes you wish to
ignore.

* `after_create`: Callback that takes the newly built object, and the original
attributes. Specially useful when combined with ignore.

```ruby
Journeyman.define :employee do |c|
  c.find { |id| Person.find(id) }

  c.build { |attrs|
    attrs.delete(:company).new_employee(attrs)
  }

  c.ignore :work_history

  c.after_create { |employee, attrs|
    attrs[:work_history].each do |history|
      check_references(history)
    end
  }
end
```

#### Configuration Options
Configuration options can be passed alongside the name in the factory definition:

* `parent:` Name of the factory that is going to be used as a parent, if `parent`
is set, the default builder consists of invoking the parent factory builder.

* `model:` Expects a class that will be used for the default builder and finder.
Useful for cases where the inferrence from the name does not work, or the factory
name is simply different than the object class it's building.

* `finder_attribute:` Name of the attribute used to find an object by the default
finder. The default is `:name`.

```ruby
Journeyman.define :employee, model: People, finder_attribute: :social_security_id do
...
end

Journeyman.define :journeyman, parent: :employee do
...
end
```

## Setup
```ruby
# Gemfile
group :test do
  gem 'journeyman'
end

# Generic Use (mock script)
require 'journeyman'

Journeyman.load(self)
````
### RSpec
```ruby
# spec/support/spec_helper.rb or similar
require 'journeyman'

Journeyman.load(self, framework: :rspec)
````

### Cucumber
```ruby
# features/support/journeyman.rb or similar
require 'journeyman'

Journeyman.load(self, framework: :cucumber)
````

## Advantages

* You have full control of how your objects are created, *and* have to write
less boilerplate.
* You can chain several factories using parent, which allows you to create
different factories for the same object with less effort.
* Code is highly optimized, so the library is much faster than say, FactoryGirl,
specially when building objects without database interaction.


### Examples

You can check the [specs](https://github.com/ElMassimo/journeyman/tree/master/spec) of the project
to check how to check some basic factories, and learn how to set it up.

## Notes
* The DSL does not use instance_exec to allow access to the external context.


License
--------

    Copyright (c) 2014 Máximo Mussini

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
