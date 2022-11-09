require 'route_mechanic/testing/methods'
require 'rspec/matchers/composable'

module RouteMechanic
  module RSpec
    module Matchers
      class BaseMatcher
        include ::RSpec::Matchers::Composable
        include RouteMechanic::Testing::Methods

        # @param [Rails::Application] expected
        def initialize(expected, extra_controllers: [], ignore_controllers: [])
          @expected = expected
          @extra_controllers = extra_controllers
          @ignore_controllers = ignore_controllers
        end

        def matches?(_actual)
          raise NotImplementedError
        end

        def failure_message
          @rescued_exception.message
        end

        def description
          raise NotImplementedError
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
    end
  end
end
