require "route_mechanic/testing/route_wrapper"
require "route_mechanic/testing/error_inspector"
require "route_mechanic/testing/error_aggregator"
require "action_controller"
require "action_controller/test_case"

module RouteMechanic
  module Testing
    module Methods
      include ActionDispatch::Assertions

      # @raise [Minitest::AssertionError]
      def assert_route_conforms
        # Instead of including ActionController::TestCase::Behavior, set up
        # https://github.com/rails/rails/blob/5b6aa8c20a3abfd6274c83f196abf73cacb3400b/actionpack/lib/action_controller/test_case.rb#L519-L520
        @controller = nil unless defined? @controller

        aggregator = ErrorAggregator.new(filter_routes, controllers).aggregate
        aggregator.all_routes.each { |wrapper| assert_routes(wrapper) }

        check_aggregated_result(aggregator)
      end

      private

      # @abstract
      # @return [ActionDispatch::Routing::RouteSet]
      def user_routes
        raise NotImplementedError, "Need to give test target routes"
      end

      # @return [ActionDispatch::Routing::RouteSet]
      def application_routes
        # assert_routing expect @routes to exists like this class inherits ActionController::TestCase.
        # Let users give routes instead of referring Rails.application.routes directly here.
        @routes ||= user_routes
      end

      # @param [RouteMechanic::Testing::RouteWrapper] wrapper
      # @raise [Minitest::AssertionError]
      def assert_routes(wrapper)
        required_parts = wrapper.required_parts.reduce({}) do |memo, required_part|
          memo.merge({ required_part => '1' })
        end

        url = application_routes.url_helpers.url_for({ controller: wrapper.controller, action: wrapper.action, only_path: true }.merge(required_parts))
        expected_options = { controller: wrapper.controller, action: wrapper.action }.merge(required_parts)
        assert_routing({ path: url, method: wrapper.verb }, expected_options)
      end

      # @return [Array<Controller>]
      def controllers
        eager_load_controllers
        ApplicationController.descendants
      end

      def eager_load_controllers
        # If complicated controllers path is used, use Rails.application.eager_load! instead.
        load_path = "#{Rails.root.join('app/controllers')}"
        relname_range = (load_path.to_s.length + 1)...-3
        Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
          require_dependency file[relname_range]
        end
      end

      # @return [Array<ActionDispatch::Journey::Route>]
      def filter_routes
        application_routes.routes.reject do |journey_route|
          # Skip internals, endpoints that Rails adds by default
          # Also Engines should be skipped since Engine's tests should be done in Engine
          wrapper = RouteWrapper.new(journey_route)
          wrapper.internal? || wrapper.required_defaults.empty? || wrapper.path.start_with?('/rails/')
        end
      end

      # @param [RouteMechanic::Testing::ErrorAggregator] aggregator
      # @raise [Minitest::AssertionError]
      def check_aggregated_result(aggregator)
        assert aggregator.no_error?, ErrorInspector.new(aggregator).message
      end
    end
  end
end
