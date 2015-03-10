require 'active_record'
require 'pry'

Dir.glob('./lib/*').each do |file|
  require file
end

ActiveRecord::Base.establish_connection(
  :adapter =>  'postgresql',
  :username => 'weekly_workshop',
  :database => 'active_record_basics'
)
