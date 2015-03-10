require 'active_record'
Dir.glob('./lib/*').each do |folder|
  Dir.glob(folder + "/*.rb").each do |file|
    require file
  end
end

ActiveRecord::Base.establish_connection(
   :adapter =>  'postgresql',
   :username => 'weekly_workshop',
   :database => 'active_record_basics'
)
