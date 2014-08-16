module Journeyman
  module Load

    attr_accessor :factories_paths

    def self.extended(journeyman)
      journeyman.factories_paths = %w(spec/factories)
    end

    # Internal: Loads all the factory files and processes the factory definitions.
    def load_factories
      absolute_factories_paths.each do |path|
        load_factories_if_file(path)
        load_factories_if_directory(path)
      end
    end

    private

    # Internal: Builds the absolute path for the factories location.
    def absolute_factories_paths
      if root_path
        factories_paths.map { |path| root_path.join(path) }
      else
        factories_paths.map { |path| File.expand_path(path) }.uniq
      end
    end

    # Internal: If the path matches a file, it loads the factories defined in it.
    def load_factories_if_file(path)
      Kernel.load("#{path}.rb") if File.exists?("#{path}.rb")
    end

    # Internal: If the path is a directory, it loads all the factories in that path.
    def load_factories_if_directory(path)
      if File.directory?(path)
        Dir[File.join(path, '**', '*.rb')].sort.each { |file| Kernel.load file }
      end
    end

    # Internal: Returns the root path of the project
    # TODO: Extract Rails and Sinatra integration.
    def root_path
      defined?(Rails) && Rails.root ||
      defined?(Sinatra::Application) && Pathname.new(Sinatra::Application.root) ||
      defined?(ROOT_DIR) && Pathname.new(ROOT_DIR)
    end
  end
end
