module Journeyman

  # Public: Provides a DSL for configuration of the factories.
  class Configuration

    METHOD_OPTIONS = [:finder, :builder, :processor]

    OPTIONS = [
      :parent, :defaults, :finder_attribute, # Public
      :static_defaults, :dynamic_defaults, :after_create_callback # Internal
    ]

    # Internal: Name of the factory, and configuration options.
    attr_reader :name, :options

    # Public: Receives the name of the factory, and configuration options.
    #
    # Yields itself to the block passed to the `Journeyman.define`.
    def initialize(name, options, config)
      @name, @options = name, options
      extract_defaults config.call(self)
      verify_valid_or_exit
    end

    # Public: DSL to configure a Journeyman definition. The following are only
    # the methods that take a block, other configuration options exist but take
    # a single argument.

    # Public: Defines how to find an instance.
    #
    #  find { |id|
    #    User.find_by(name_or_email(id) => id)
    #  }
    #
    # Yields the find argument passed to the `find_#{name}` method.
    def find(proc=nil, &block)
      options[:finder] = proc || block
    end

    # Public: Defines how to build an instance. Highly customizable.
    #
    #  build { |attributes|
    #    blueprint, patient = attributes.delete(:blueprint), attributes.delete(:patient)
    #    blueprint.enroll(patient)
    #  }
    #
    # Yields the arguments passed to the `build_#{name}` method after adding the
    # defaults and invoking the processor.
    def build(proc=nil, &block)
      options[:builder] ||= proc || block
    end

    # Public: Attributes processor, allows to modify the passed attributes
    # before building an instance.
    def process(proc=nil, &block)
      options[:processor] ||= proc || block
    end

    # Public: Allows to ignore certain attributes, that can be accessed in the
    # after_create callback.
    def ignore(*ignored)
      options[:ignored] = ->(attrs) do
        attrs = attrs.dup; ignored.each { |key| attrs.delete(key) }; attrs
      end
    end

    # Public: Invoked after creating an object, useful for setting up secondary
    # or optional relations.
    def after_create(proc=nil, &block)
      options[:after_create_callback] ||= proc || block
    end


    # Internal: Configuration Options provided for the Journeyman builder. Here
    # is where you can stop reading unless you are interested in the internals.

    # Internal: Class of the model to build, used in the default build strategy.
    def model
      options[:model] ||= infer_model_class(name)
    end

    # Internal: Returns the finder proc, or the default finder strategy.
    def finder
      options[:finder] ||= default_finder
    end

    # Internal: Returns the finder proc, or the default builder strategy.
    def builder
      options[:builder] ||= parent_builder || default_builder
    end

    # Internal: Returns a custom processor, or ignore directive.
    def processor
      options[:ignored] || options[:processor]
    end

    private

    # Internal: Default finder strategy used.
    def default_finder
      options[:finder_attribute] ||= :name
      ->(name) { model.find_by(finder_attribute => name) }
    end

    # Internal: Creates the object by simply using the initializer.
    def default_builder
      ->(attrs={}) { model.new(attrs) }
    end

    # Internal: Uses the builder of the parent to construct the object.
    #
    # Returns the builder if a :parent was set, or nil.
    def parent_builder
      ->(attrs={}) { Journeyman.build(parent, attrs) } if parent
    end

    # Internal: Prepares the default arguments for the builder.
    # The return value of the configuration block may provide the defaults.
    #
    # result - The return value of the configuration block.
    #
    # Returns nothing.
    def extract_defaults(result)
      defaults = options[:defaults] || (result if result.is_a?(Hash)) || {}

      options[:dynamic_defaults], options[:static_defaults] = partition_defaults(defaults)
    end

    # Internal: Splits static from dynamic arguments for runtime performance.
    def partition_defaults(defaults)
      defaults.partition { |key, value| value.is_a?(Proc) }.map(&:to_h)
    end

    # Internal: Infers a model class.
    def infer_model_class(name)
      if defined? ActiveSupport
        name.to_s.classify.constantize
      else
        Object.const_get(name.to_s.split('_').collect!{ |w| w.capitalize }.join)
      end
    end

    # Internal: Checks the configuration's consistency
    def verify_valid_or_exit
      if options[:parent] && options[:builder]
        raise InvalidArgumentError, 'custom builder can not be used in combination with `parent: true`'
      end
      if options[:ignored] && options[:processor]
        raise InvalidArgumentError, 'custom processor can not be used in combination with `ignore`'
      end
    end

    # Internal: Performance optimization, the option method is defined the first
    # time it's accessed.
    def self.define_option_method(name)
      class_eval <<-OPTION
        def #{name}(value=nil)
          options[:#{name}] = value if value
          options[:#{name}]
        end
      OPTION
    end

    OPTIONS.each do |name|
      define_option_method(name)
    end
  end
end
