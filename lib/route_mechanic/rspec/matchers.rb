require 'route_mechanic/rspec/matchers/have_valid_routes'
require 'route_mechanic/rspec/matchers/have_no_unused_actions'
require 'route_mechanic/rspec/matchers/have_no_unused_routes'

module RouteMechanic
  module RSpec
    module Matchers
      def have_valid_routes(application=Rails.application, extra_controllers: [], ignore_controllers: [])
        HaveValidRoutes.new(application, extra_controllers: extra_controllers, ignore_controllers: ignore_controllers)
      end

      def have_no_unused_actions(application=Rails.application, extra_controllers: [], ignore_controllers: [])
        HaveNoUnusedActions.new(application, extra_controllers: extra_controllers, ignore_controllers: ignore_controllers)
      end

      def have_no_unused_routes(application=Rails.application, extra_controllers: [], ignore_controllers: [])
        HaveNoUnusedRoutes.new(application, extra_controllers: extra_controllers, ignore_controllers: ignore_controllers)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RouteMechanic::RSpec::Matchers, type: :routing
end
