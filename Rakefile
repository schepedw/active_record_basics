require 'rake/testtask'
ROLE = 'weekly_workshop'
DB = 'active_record_basics'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "*_spec.rb"
end

namespace :db do
  desc "Create missing PG roles"
  task :create_roles do
    sh "createuser --createdb --login #{ROLE}|| echo Already exists."
  end

  task :create do
    sh "createdb -O weekly_workshop #{DB}"
  end

end

def sh(command, cwd = root)
  Dir.chdir(cwd) do
    env = { 'BUNDLE_GEMFILE' => nil, 'RUBYOPT' => nil }
    command = "source #{Eb.path('script', 'ruby-env.sh')} ; #{command}"
    cmd = Shellwords.join [ENV['SHELL'], '-l', '-c', command]
    system(env, cmd)
  end
end
