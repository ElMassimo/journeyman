require 'rspec/given'
require 'pry'
require 'pry-stack_explorer'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require './lib/journeyman'
Journeyman.load(self, framework: :rspec)
