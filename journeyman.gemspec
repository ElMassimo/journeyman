Gem::Specification.new do |s|
  s.name = "journeyman"
  s.version = '0.1.0'
  s.licenses = ['MIT']
  s.summary = "Let your factories use your business logic, keeping them flexible and making them easier to update."
  s.description = "Journeyman allows you to define factories with custom build methods, allowing you to easily bend object creation to the nuances of your application and domain. This means you can rely more in Ruby, and less on your ORM"
  s.authors = ["Máximo Mussini"]

  s.email = ["maximomussini@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir.glob("{lib}/**/*.rb") + %w(README.md)
  s.homepage = %q{https://github.com/ElMassimo/journeyman}

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=2.0.0'
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
end
