module RouteMechanic
  module Testing
    class ErrorInspector
      def initialize(controller_routes_errors, config_routes_errors)
        @controller_routes_errors = controller_routes_errors
        @config_routes_errors = config_routes_errors
      end

      def message
        buffer = []

        if @controller_routes_errors.present?
          buffer << "  No route matches to the controllers and action methods below"
          buffer << @controller_routes_errors.map {|r| "    #{r[:controller]}##{r[:action]}" }
        end

        if @config_routes_errors.present?
          verb_width, path_width = widths
          buffer << "  No controller and action matches to the routes below"
          buffer << @config_routes_errors.map { |w| "    #{w.verb.ljust(verb_width)} #{w.path.ljust(path_width)} #{w.reqs}" }
          buffer << "\n"
        end

        ["[Route Mechanic]", buffer].join("\n")
      end

      private

      def widths
        [
          @config_routes_errors.map { |w| w.verb.length }.max || 0,
          @config_routes_errors.map { |w| w.path.length }.max || 0
        ]
      end
    end
  end
end
