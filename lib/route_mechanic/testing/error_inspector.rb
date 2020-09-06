require 'forwardable'

module RouteMechanic
  module Testing
    class ErrorInspector
      extend Forwardable
      def_delegators :@aggregator, :controller_routes_errors, :config_routes_errors

      # @param [RouteMechanic::Testing::ErrorAggregator] aggregator
      def initialize(aggregator)
        @aggregator = aggregator
      end

      # @return [String]
      def message
        buffer = []

        if controller_routes_errors.present?
          buffer << "  No route matches to the controllers and action methods below"
          buffer << controller_routes_errors.map {|r| "    #{r[:controller]}##{r[:action]}" }
        end

        if config_routes_errors.present?
          verb_width, path_width = widths
          buffer << "  No controller and action matches to the routes below"
          buffer << config_routes_errors.map { |w| "    #{w.verb.ljust(verb_width)} #{w.path.ljust(path_width)} #{w.reqs}" }
          buffer << "\n"
        end

        ["[Route Mechanic]", buffer].join("\n")
      end

      private

      def widths
        [
          config_routes_errors.map { |w| w.verb.length }.max || 0,
          config_routes_errors.map { |w| w.path.length }.max || 0
        ]
      end
    end
  end
end
