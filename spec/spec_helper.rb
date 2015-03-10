require_relative '../environment'
require 'factory_girl'

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'rspec'
require_relative "../db/seeds.rb"


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  #FactoryGirl.definition_file_paths = Dir[Rails.root.join("postmen/*/spec/factories")]
  FactoryGirl.find_definitions

end
