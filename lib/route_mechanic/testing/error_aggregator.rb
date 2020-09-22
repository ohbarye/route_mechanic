require "route_mechanic/testing/error_inspector"

module RouteMechanic
  module Testing
    class ErrorAggregator
      attr_reader :unused_actions_errors, :unused_routes_errors

      # @param [Array<ActionDispatch::Journey::Route>] routes
      # @param [Array<Controller>] controllers
      def initialize(routes, controllers)
        @routes = routes
        @controllers = controllers
        @config_routes = []
        @controller_routes = []
        @unused_routes_errors = []
        @unused_actions_errors = []
      end

      # @param [Boolean] unused_actions
      # @param [Boolean] unused_routes
      def aggregate(unused_actions: true, unused_routes: true)
        collect_unused_actions_errors(unused_actions)
        collect_unused_routes_errors(unused_routes)
        self
      end

      # @return [Array<ActionDispatch::Journey::Route>]
      def all_routes
        @config_routes + @controller_routes
      end

      # @return [Boolean]
      def no_error?
        [@unused_routes_errors, @unused_actions_errors].all?(&:empty?)
      end

      # @return [String]
      def error_message
        ErrorInspector.new(self).message
      end

      private

      def collect_unused_actions_errors(report_error)
        @controllers.each do |controller|
          controller_path = controller.controller_path
          controller.action_methods.each do |action_method|
            journey_routes = @routes.select do |route|
              route.defaults[:controller].to_sym == controller_path.to_sym && route.defaults[:action].to_sym == action_method.to_sym
            end

            if journey_routes.empty?
              @unused_actions_errors << { controller: controller, action: action_method } if report_error
            else
              wrappers = journey_routes.map { |r| RouteWrapper.new(r) }
              @controller_routes.concat(wrappers)
            end
          end
        end
      end

      def collect_unused_routes_errors(report_error)
        @routes.each do |journey_route|
          wrapper = RouteWrapper.new journey_route
          @config_routes << wrapper

          matched_controller_exist = @controller_routes.any? do |w|
            wrapper.controller == w.controller && wrapper.action == w.action && wrapper.path == w.path
          end

          @unused_routes_errors << wrapper if !matched_controller_exist && report_error
        end
      end
    end
  end
end
