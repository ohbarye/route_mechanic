require "route_mechanic/testing/route_wrapper"
require "route_mechanic/testing/error_aggregator"
require "route_mechanic/testing/minitest_assertion_adopter"
require "action_controller"
require "action_controller/test_case"
require "regexp-examples"

module RouteMechanic
  module Testing
    module Methods
      include MinitestAssertionAdapter if defined?(RSpec)
      include ActionDispatch::Assertions

      # @param [Rails::Application] application
      # @raise [Minitest::Assertion]
      def assert_all_routes(application=Rails.application, extra_controllers: [], ignore_controllers: [])
        assert_targets(application, unused_actions: true, unused_routes: true, extra_controllers: extra_controllers, ignore_controllers: ignore_controllers)
      end

      # @param [Rails::Application] application
      # @raise [Minitest::Assertion]
      def assert_no_unused_actions(application=Rails.application, extra_controllers: [], ignore_controllers: [])
        assert_targets(application, unused_actions: true, unused_routes: false, extra_controllers: extra_controllers, ignore_controllers: ignore_controllers)
      end

      # @param [Rails::Application] application
      # @raise [Minitest::Assertion]
      def assert_no_unused_routes(application=Rails.application, extra_controllers: [], ignore_controllers: [])
        assert_targets(application, unused_actions: false, unused_routes: true, extra_controllers: extra_controllers, ignore_controllers: ignore_controllers)
      end

      private

      # @param [Rails::Application] application
      # @param [Boolean] unused_actions
      # @param [Boolean] unused_routes
      # @raise [Minitest::Assertion]
      def assert_targets(application, unused_actions:, unused_routes:, extra_controllers: [], ignore_controllers: [])
        @application = application

        # Instead of including ActionController::TestCase::Behavior, set up
        # https://github.com/rails/rails/blob/5b6aa8c20a3abfd6274c83f196abf73cacb3400b/actionpack/lib/action_controller/test_case.rb#L519-L520
        @controller = nil unless defined? @controller

        aggregator = ErrorAggregator.new(target_routes, controllers + extra_controllers - ignore_controllers).aggregate(
          unused_actions: unused_actions, unused_routes: unused_routes)
        aggregator.all_routes.each { |wrapper| assert_routes(wrapper) }

        assert(aggregator.no_error?, ->{ aggregator.error_message })
      end

      def routes
        # assert_routing expect @routes to exists as like this class inherits ActionController::TestCase.
        # If user already defines @routes, do not override
        @routes ||= @application.routes

        return @routes if @routes.routes.size > 0

        # If routes setting is not loaded when running test, it automatically loads config/routes as Rails does.
        load_path = "#{Rails.root.join('config/routes.rb')}"
        @application.routes_reloader.paths << load_path unless @application.routes_reloader.paths.include? load_path
        @application.reload_routes!
        @routes
      end

      # @param [RouteMechanic::Testing::RouteWrapper] wrapper
      # @raise [Minitest::Assertion]
      def assert_routes(wrapper)
        required_parts = wrapper.required_parts.reduce({}) do |memo, required_part|
          dummy = if wrapper.requirements[required_part].is_a?(Regexp)
                    wrapper.requirements[required_part].random_example
                  else
                    '1'
                  end
          memo.merge({ required_part => dummy }) # Set pseudo params to meets requirements
        end

        base_option = { controller: wrapper.controller, action: wrapper.action }
        url = routes.url_helpers.url_for(
          base_option.merge({ only_path: true }).merge(required_parts))
        expected_options = base_option.merge(required_parts)

        assert_generates(url, expected_options)
        # Q. Why not using `assert_routing` or `assert_recognize`?
        # A. They strictly checks `constraints` in routes.rb and
        #    this gem can't generate a request that meets whole constraints just in time.
        # https://github.com/ohbarye/route_mechanic/issues/7#issuecomment-695957142
        # https://guides.rubyonrails.org/routing.html#specifying-constraints
      end

      # @return [Array<Controller>]
      def controllers
        eager_load_controllers.map { |controller|
          controller.gsub(%r{.+app/controllers/}, '')[0..-4].classify.constantize
        }
      end

      # In RAILS_ENV=test, eager load is false and `ApplicationController.descendants` might be empty.
      # So it needs to load all controllers. To shorten loading time, it loads only controllers.
      # If complicated controllers path is used, use Rails.application.eager_load! instead.
      def eager_load_controllers
        load_path = "#{Rails.root.join('app/controllers')}"
        Dir.glob("#{load_path}/**/*_controller.rb").sort.each do |file|
          require_dependency file
        end
      end

      # @return [Array<ActionDispatch::Journey::Route>]
      def target_routes
        routes.routes.reject do |journey_route|
          # Skip internals, endpoints that Rails adds by default
          # Also Engines should be skipped since Engine's tests should be done in Engine
          wrapper = RouteWrapper.new(journey_route)
          wrapper.internal? || !wrapper.defaults[:controller] || !wrapper.defaults[:action] || wrapper.path.start_with?('/rails/')
        end
      end
    end
  end
end
