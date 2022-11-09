require 'route_mechanic/rspec/matchers/base_matcher'

module RouteMechanic
  module RSpec
    module Matchers
      class HaveNoUnusedActions < BaseMatcher
        def matches?(_actual)
          # assert_recognizes does not consider ActionController::RoutingError an
          # assertion failure, so we have to capture that and Assertion here.
          match_unless_raises Minitest::Assertion, ActiveSupport::TestCase::Assertion, ActionController::RoutingError do
            assert_no_unused_actions(@expected, extra_controllers: @extra_controllers, ignore_controllers: @ignore_controllers)
          end
        end

        def description
          "have no unused actions"
        end
      end
    end
  end
end
