require "route_mechanic/version"
require "route_mechanic/testing/methods"
require "route_mechanic/rspec/matchers" if defined?(RSpec)

module RouteMechanic
  class Error < StandardError; end
end
