$LOAD_PATH << File.join(__dir__, 'lib')

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :example do
  require 'pv'
  500.times.pv do |n|
    puts 'Some output' if n % 123 == 0
    sleep rand / 50
  end
end

task :slow_example do
  require 'pv'
  8.times.pv do |n|
    puts 'Some output' if n == 3 || n == 7
    sleep 0.5
  end
end

task :unsized_example do
  require 'pv'
  125.times.to_enum.pv do |n|
    sleep n < 25 ? 0.1 : 0.025
  end
end

task :unsized_slow_example do
  require 'pv'
  50.times.to_enum.pv do
    sleep 0.5
  end
end
