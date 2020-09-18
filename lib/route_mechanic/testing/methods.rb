require "route_mechanic/testing/route_wrapper"
require "route_mechanic/testing/error_aggregator"
require "route_mechanic/testing/minitest_assertion_adopter"
require "action_controller"
require "action_controller/test_case"

module RouteMechanic
  module Testing
    module Methods
      include MinitestAssertionAdapter if defined?(RSpec)
      include ActionDispatch::Assertions

      # @param [ActionDispatch::Routing::RouteSet] routes
      # @raise [Minitest::Assertion]
      def assert_all_routes(routes=Rails.application.routes)
        # assert_routing expect @routes to exists as like this class inherits ActionController::TestCase.
        # If user already defines @routes, do not override
        @routes ||= routes

        # Instead of including ActionController::TestCase::Behavior, set up
        # https://github.com/rails/rails/blob/5b6aa8c20a3abfd6274c83f196abf73cacb3400b/actionpack/lib/action_controller/test_case.rb#L519-L520
        @controller = nil unless defined? @controller

        aggregator = ErrorAggregator.new(target_routes, controllers).aggregate
        aggregator.all_routes.each { |wrapper| assert_routes(wrapper) }

        assert(aggregator.no_error?, ->{ aggregator.error_message })
      end

      private

      # @param [RouteMechanic::Testing::RouteWrapper] wrapper
      # @raise [Minitest::Assertion]
      def assert_routes(wrapper)
        required_parts = wrapper.required_parts.reduce({}) do |memo, required_part|
          memo.merge({ required_part => '1' }) # '1' is pseudo id
        end

        base_option = { controller: wrapper.controller, action: wrapper.action }
        url = @routes.url_helpers.url_for(
          base_option.merge({ only_path: true }).merge(required_parts))
        expected_options = base_option.merge(required_parts)

        assert_routing({ path: url, method: wrapper.verb }, expected_options)
      end

      # @return [Array<Controller>]
      def controllers
        eager_load_controllers
        ApplicationController.descendants
      end

      # In RAILS_ENV=test, eager load is false and `ApplicationController.descendants` might be empty.
      # So it needs to load all controllers. To shorten loading time, it loads only controllers.
      # If complicated controllers path is used, use Rails.application.eager_load! instead.
      def eager_load_controllers
        load_path = "#{Rails.root.join('app/controllers')}"
        relname_range = (load_path.to_s.length + 1)...-3
        Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
          require_dependency file[relname_range]
        end
      end

      # @return [Array<ActionDispatch::Journey::Route>]
      def target_routes
        @routes.routes.reject do |journey_route|
          # Skip internals, endpoints that Rails adds by default
          # Also Engines should be skipped since Engine's tests should be done in Engine
          wrapper = RouteWrapper.new(journey_route)
          wrapper.internal? || wrapper.required_defaults.empty? || wrapper.path.start_with?('/rails/')
        end
      end
    end
  end
end
