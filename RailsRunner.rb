#!/usr/bin/ruby
 
Dir.chdir(ENV['RAILS_ROOT'])
 
require 'config/boot'
require 'active_support'
require 'action_controller'
require 'fileutils'
 
options = {
  :Port => 3000,
  :Host => "0.0.0.0",
  :environment => (ENV['RAILS_ENV'] || "development").dup,
  :config => RAILS_ROOT + "/config.ru",
  :detach => false,
  :debugger => false
}
 
server = Rack::Handler::LSWS
 
if File.exist?(options[:config])
  config = options[:config]
  if config =~ /\.ru$/
    cfgfile = File.read(config)
    if cfgfile[/^#\\(.*)/]
      opts.parse!($1.split(/\s+/))
    end
    inner_app = eval("Rack::Builder.new {( " + cfgfile + "\n )}.to_app", nil, config)
  else
    require config
    inner_app = Object.const_get(File.basename(config, '.rb').capitalize)
  end
else
  require 'config/environment'
  inner_app = ActionController::Dispatcher.new
end
 
app = Rack::Builder.new {
  use Rails::Rack::Static
  use Rails::Rack::Debugger if options[:debugger]
  run inner_app
}.to_app
 
puts "=> Call with -d to detach"
 
ActiveRecord::Base.clear_active_connections! if defined?(ActiveRecord::Base)
 
begin
  server.run(app, options.merge(:AccessLog => []))
ensure
  puts 'Exiting'
end
