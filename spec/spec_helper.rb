require 'rspec/given'
require 'stub_constant'
require 'pry'
require 'pry-stack_explorer'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require './lib/journeyman'
Journeyman.load(self, framework: :rspec)
