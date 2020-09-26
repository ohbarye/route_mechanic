require 'route_mechanic/rspec/matchers/have_valid_routes'

module RouteMechanic
  module RSpec
    module Matchers
      def have_valid_routes(application=Rails.application)
        HaveValidRoutes.new(application)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RouteMechanic::RSpec::Matchers, type: :routing
end
