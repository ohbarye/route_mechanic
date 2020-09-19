require 'route_mechanic/testing/methods'
require 'rspec/matchers/composable'

module RouteMechanic
  module RSpec
    module Matchers
      class HaveValidRoutes
        include ::RSpec::Matchers::Composable
        include RouteMechanic::Testing::Methods

        # @param [Rails::Application] expected
        def initialize(expected)
          @expected = expected
        end

        def matches?(_actual)
          # assert_recognizes does not consider ActionController::RoutingError an
          # assertion failure, so we have to capture that and Assertion here.
          match_unless_raises Minitest::Assertion, ActiveSupport::TestCase::Assertion, ActionController::RoutingError do
            assert_all_routes(@expected)
          end
        end

        def failure_message
          @rescued_exception.message
        end

        def description
          "have valid routes"
        end

        private

        def match_unless_raises(*exceptions)
          exceptions.unshift Exception if exceptions.empty?
          begin
            yield
            true
          rescue *exceptions => @rescued_exception
            false
          end
        end
      end

      def have_valid_routes(application=Rails.application)
        HaveValidRoutes.new(application)
      end
    end
  end
end

RSpec.configure do |config|
  config.include RouteMechanic::RSpec::Matchers, type: :routing
end
