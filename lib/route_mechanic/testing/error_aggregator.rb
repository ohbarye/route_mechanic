module RouteMechanic
  module Testing
    class ErrorAggregator
      attr_reader :controller_routes_errors, :config_routes_errors

      # @param [Array<ActionDispatch::Journey::Route>] routes
      # @param [Array<Controller>] controllers
      def initialize(routes, controllers)
        @routes = routes
        @controllers = controllers
        @config_routes = []
        @controller_routes = []
        @config_routes_errors = []
        @controller_routes_errors = []
      end

      def aggregate
        collect_controller_routes_errors
        collect_config_routes_errors
        self
      end

      def all_routes
        @config_routes + @controller_routes
      end

      def no_error?
        [@config_routes_errors, @controller_routes_errors].all?(&:empty?)
      end

      private

      def collect_controller_routes_errors
        @controllers.each do |controller|
          controller_path = controller.controller_path
          controller.action_methods.each do |action_method|
            journey_route = @routes.detect do |route|
              route.defaults[:controller].to_sym == controller_path.to_sym && route.defaults[:action].to_sym == action_method.to_sym
            end

            if journey_route
              wrapper = RouteWrapper.new journey_route
              @controller_routes << wrapper
            else
              @controller_routes_errors << { controller: controller, action: action_method }
            end
          end
        end
      end

      def collect_config_routes_errors
        @routes.each do |journey_route|
          wrapper = RouteWrapper.new journey_route
          @config_routes << wrapper

          matched_controller_exist = @controller_routes.any? do |w|
            wrapper.controller == w.controller && wrapper.action == w.action && wrapper.path == w.path
          end

          @config_routes_errors << wrapper unless matched_controller_exist
        end
      end
    end
  end
end
