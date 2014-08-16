require 'journeyman/configuration'

# Internal: Builds and creates objects, using the configuration provided.
module Journeyman
  class Builder
    extend Forwardable

    attr_reader :config
    def_delegators(:config, *Configuration::OPTIONS, *Configuration::METHOD_OPTIONS, :name)

    def initialize(name, options, config)
      @config = Configuration.new(name, options, config)
    end

    # Internal: Executes the finder.
    def find(id)
      config.finder.call(id)
    end

    # Internal: Builds a new instance, using the configuration specified in the
    # factory.
    #
    # attrs - The attributes used to build the object
    #
    # Returns a new instance of the object.
    def build(attrs={})
      check_build_arguments(attrs)
      attrs = merge_defaults(attrs)
      attrs = Journeyman.execute(processor, attrs) if processor
      config.builder.call(attrs)
    end

    # Internal: Create a new instance, using the configuration specified in the
    # factory.
    #
    # attrs - The attributes used to build the object
    #
    # Returns a new instance of the object.
    def create(attrs={})
      build(attrs).tap { |instance|
        instance.save!
        Journeyman.execute(after_create_callback, instance, attrs)
      }
    end

    private

    # Internal: Merges the default attributes to the specified attributes Hash.
    #
    # Returns the modified Hash.
    def merge_defaults(attributes={})
      attributes.tap do |attrs|
        attrs.merge!(static_defaults){ |key, user, default| user } # Reverse Merge
        dynamic_defaults.each { |key, value| attrs[key] ||= Journeyman.execute(value, attrs) }
      end
    end

    # Internal: Checks the attributes to make sure it's a Hash, to provide more
    # insight on wrong usage.
    def check_build_arguments(attrs)
      unless attrs.is_a?(Hash)
        raise ArgumentError, "Journeyman expected a Hash, but received: #{attrs}"
      end
    end
  end
end
