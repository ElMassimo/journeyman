# Internal: Integrations with testing frameworks.
module Journeyman
  module Integration

    # Internal: Sets up the integration with the framework being used.
    def setup_integration(env, framework)
      case framework
      when :rspec then setup_rspec_integration(env)
      when :cucumber then setup_cucumber_integration(env)
      else setup_default_integration(env)
      end
    end

    private

    # Internal: Sets up the default integration, which is helpful for console and
    # mock scripts.
    def setup_default_integration(env)
      env.send :include, @helpers
      Journeyman.attach(env)
    end

    # Internal: Attaches Journeyman to the RSpec context, and adds the helpers.
    def setup_rspec_integration(env)
      RSpec.configure do |config|
        config.include @helpers
        config.before(:each) { Journeyman.attach(self) }
      end
    end

    # Internal: Attaches Journeyman to the Cucumber context, and adds the helpers.
    def setup_cucumber_integration(cucumber)
      cucumber.World(@helpers)
      cucumber.Before { Journeyman.attach(self) }
    end
  end
end
