require 'journeyman/load'
require 'journeyman/integration'
require 'journeyman/definition'
require 'journeyman/missing_factory_error'

# Public: Allows to define and use factory methods. It is capable of providing
# `build`, `create`, `find`, and `default` methods, the last two are optional.
#
# Examples:
#
#   Journeyman.define :user do |t|
#     {
#       name: "Johnnie Walker",
#       date_of_birth: ->{ 150.years.ago }
#     }
#   end
#
#   Journeyman.build(:user)  => build_user
#   Journeyman.create(:user) => create_user
#
module Journeyman
  extend Load
  extend Integration
  extend Definition

  # Public: Initializes Journeyman by loading the libraries, attaching to the
  # current context, and configuring the testing libraries.
  def self.load(env, framework: nil)
    @helpers = Module.new
    attach(env)
    load_factories
    setup_integration(env, framework)
  end

  # Public: Attaches Journeyman to the specified context, which enables the use
  # of the convenience acessors for the factory methods, like `Journeyman.build`.
  def self.attach(context)
    @context = context
  end

  # Public: Convenience accessor for build methods.
  def self.build(name, *args, &block)
    send(name, "build_#{name}", *args, &block)
  end

  # Public: Convenience accessor for create methods.
  def self.create(name, *args, &block)
    send(name, "create_#{name}", *args, &block)
  end

  # Public: Convenience accessor for default methods.
  def self.default(name)
    send(name, "default_#{name}")
  end

  # Internal: Call a factory method in the context.
  def self.send(factory_name, method_name, *args, &block)
    if @context.respond_to?(method_name)
      @context.send(method_name, *args, &block)
    else
      raise MissingFactoryError, "'#{factory_name}' factory is not defined"
    end
  end

  # Internal: Executes a proc in the context that is currently attached.
  def self.execute(proc, *args)
    if proc
      if proc.arity == 0
        @context.instance_exec(&proc)
      else
        @context.instance_exec(*args, &proc)
      end
    end
  end
end
