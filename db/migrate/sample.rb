require_relative '../../environment'
require 'pry'

class SampleMigration < ActiveRecord::Migration
  def up
    puts 'ran up'
  end

  def down
    puts 'ran down'
  end
end

SampleMigration.migrate(ARGV[0].to_sym)
