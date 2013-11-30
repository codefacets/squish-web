# this loads the engine
require 'squash/ruby'
require 'squash/rails'
require 'squash/symbolicator'
require 'squash/javascript'
require 'squash/java'
require 'squash/engine'
require 'configoro/simple'
require 'rack/cors'
require 'jira'

# Load our frozen Configoro
require File.join(File.dirname(__FILE__), '..', 'vendor', 'configoro', 'simple')

rails_root = ENV['RAILS_ROOT'] || File.join(File.dirname(__FILE__), '..')
Configoro.paths << File.join(rails_root, 'config', 'environments')

# $_squash_environments = Dir.glob(File.join(rails_root, 'config', 'environments', '*.rb')).map { |f| File.basename f, '.rb' }
#
# def load_groups(configuration_path, values)
#   configuration_path = configuration_path.split('.')
#
#   $_squash_environments.select do |env|
#     settings = Configoro.load_environment(env)
#     values.include?(traverse_hash(settings, *configuration_path))
#   end
# end
#
# def traverse_hash(hsh, *keys)
#   if keys.size == 1
#     hsh[keys.first]
#   else
#     traverse_hash hsh[keys.shift], *keys
#   end
# end
#
# def conditionally(configuration_path, *values, &block)
#   groups = load_groups(configuration_path, values)
#   groups.each { |g| group g.to_sym, &block }
# end

if defined?(Configoro)
  Configoro.reset_paths # reset configoro
end