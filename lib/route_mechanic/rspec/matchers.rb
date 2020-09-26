require 'route_mechanic/rspec/matchers/have_valid_routes'
require 'route_mechanic/rspec/matchers/have_no_unused_actions'
require 'route_mechanic/rspec/matchers/have_no_unused_routes'

module RouteMechanic
  module RSpec
    module Matchers
      def have_valid_routes(application=Rails.application)
        HaveValidRoutes.new(application)
      end

      def have_no_unused_actions(application=Rails.application)
        HaveNoUnusedActions.new(application)
      end

      def have_no_unused_routes(application=Rails.application)
        HaveNoUnusedRoutes.new(application)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RouteMechanic::RSpec::Matchers, type: :routing
end
