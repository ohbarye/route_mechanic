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

        routes = filter_routes
        controller_routes_errors, controller_routes = collect_controller_routes_errors(routes)
        config_routes_errors = collect_config_routes_errors(routes, controller_routes)

        check_aggregated_result(controller_routes_errors, config_routes_errors)
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

      # @return [ActionDispatch::Routing::RouteSet]
      def collect_controller_routes_errors(routes)
        controller_routes = []
        controller_routes_errors = controllers.reduce([]) do |memo, controller|
          controller_path = controller.controller_path
          controller.action_methods.each do |action_method|
            journey_route = routes.detect do |route|
              route.defaults[:controller].to_sym == controller_path.to_sym && route.defaults[:action].to_sym == action_method.to_sym
            end

            if journey_route
              wrapper = ActionDispatch::Routing::RouteWrapper.new journey_route
              assert_routes(wrapper.controller, wrapper.action, wrapper.verb, wrapper.required_parts)
              controller_routes << wrapper
            else
              memo << { controller: controller, action: action_method }
            end
          end
          memo
        end
        [controller_routes_errors, controller_routes]
      end

      def assert_routes(controller_path, action_method, verb, required_parts)
        required_parts = required_parts.reduce({}) do |memo, required_part|
          memo.merge({ required_part => '1' })
        end

        url = application_routes.url_helpers.url_for({controller: controller_path, action: action_method, only_path: true}.merge(required_parts))
        expected_options = {controller: controller_path, action: action_method}.merge(required_parts)
        assert_routing({path: url, method: verb}, expected_options)
      end

      def definition(journey_route)
        wrapper = ActionDispatch::Routing::RouteWrapper.new journey_route
        assert_routes(wrapper.controller, wrapper.action, wrapper.verb, wrapper.required_parts)
        {
          controller: wrapper.controller,
          action: wrapper.action,
          path: wrapper.path,
          verb: wrapper.verb,
        }
      end

      def controllers
        @_controllers ||= begin
          eager_load_controllers
          ApplicationController.descendants
        end
      end

      def collect_config_routes_errors(routes, controller_routes)
        routes.reduce([]) do |memo, journey_route|
          wrapper = ActionDispatch::Routing::RouteWrapper.new journey_route
          assert_routes(wrapper.controller, wrapper.action, wrapper.verb, wrapper.required_parts)

          matched_controller_exist = controller_routes.any? do |w|
            wrapper.controller == w.controller && wrapper.action == w.action && wrapper.path == w.path
          end

          memo << wrapper unless matched_controller_exist
          memo
        end
      end

      def eager_load_controllers
        # If complicated controllers path is used, use Rails.application.eager_load! instead.
        load_path = "#{Rails.root.join('app/controllers')}"
        relname_range = (load_path.to_s.length + 1)...-3
        Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
          require_dependency file[relname_range]
        end
      end

      def filter_routes
        application_routes.routes.reject do |journey_route|
          # Skip internals, endpoints that Rails adds by default
          # Also Engines should be skipped since Engine's tests should be done in Engine
          wrapper = ActionDispatch::Routing::RouteWrapper.new(journey_route)
          wrapper.internal? || wrapper.required_defaults.empty? || wrapper.path.start_with?('/rails/')
        end
      end

      def check_aggregated_result(controller_routes_errors, config_routes_errors)
        if [*controller_routes_errors, *config_routes_errors].present?
          assert false, error_message(controller_routes_errors, config_routes_errors)
        else
          assert true
        end
      end

      def error_message(controller_routes_errors, config_routes_errors)
        buffer = []

        if controller_routes_errors.present?
          buffer << "  No route matches to the controllers and action methods below"
          buffer << controller_routes_errors.map {|r|
            "    #{r[:controller]}##{r[:action]}"
          }
        end

        if config_routes_errors.present?
          verb_width, path_width = widths(config_routes_errors)
          buffer << "  No controller and action matches to the routes below"
          buffer << config_routes_errors.map { |w|
            "    #{w.verb.ljust(verb_width)} #{w.path.ljust(path_width)} #{w.reqs}"
          }
          buffer << "\n"
        end

        ["[Route Mechanic]", buffer].join("\n")
      end

      def widths(routes)
        [
          routes.map { |w| w.verb.length }.max || 0,
          routes.map { |w| w.path.length }.max || 0
        ]
      end
    end
  end
end
