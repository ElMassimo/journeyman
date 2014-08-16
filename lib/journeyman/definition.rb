require 'journeyman/builder'
module Journeyman

  # Internal: Contains all the factory method definition logic.
  module Definition

    # Public: Defines a new factory for Journeyman, which consists in a build
    # and create method, and may optionally include finder and default methods.
    #
    # Returns Builder for debug purposes.
    def define(name, options={}, &config)
      finder, default = options.delete(:include_finder), options.delete(:include_default)

      Builder.new(name, options, config).tap do |builder|
        define_find_method(name, builder) unless finder == false
        define_build_method(name, builder)
        define_create_method(name, builder)
        define_default_method(name) if default
      end
    end

    private

    # Factories Definitions

    # Internal: Defines the finder method.
    def define_find_method(name, builder)
      define_helper "find_#{name}", ->(id) { builder.find(id) }
    end

    # Internal: Defines the builder method.
    def define_build_method(name, builder)
      define_helper "build_#{name}", ->(attrs={}) { builder.build(attrs) }
    end

    # Internal: Defines the create method.
    def define_create_method(name, builder)
      define_helper "create_#{name}", ->(attrs={}) { builder.create(attrs) }
    end

    # Internal: Defines the default method.
    def define_default_method(name)
      @helpers.send :class_eval, <<-EVAL
        def default_#{name}
          @#{name} ||= Journeyman.create(:'#{name}')
        end
      EVAL
    end

    # Internal: Syntax sugar to define a method in the helpers module.
    def define_helper(name, proc)
      @helpers.send :define_method, name, proc
    end
  end
end
