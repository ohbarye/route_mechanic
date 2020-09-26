require 'forwardable'

module RouteMechanic
  module Testing
    class ErrorInspector
      extend Forwardable
      def_delegators :@aggregator, :unused_actions_errors, :unused_routes_errors

      # @param [RouteMechanic::Testing::ErrorAggregator] aggregator
      def initialize(aggregator)
        @aggregator = aggregator
      end

      # @return [String]
      def message
        buffer = []

        if unused_actions_errors.present?
          buffer << "  No route matches to the controllers and action methods below"
          buffer << unused_actions_errors.map {|r| "    #{r[:controller]}##{r[:action]}" }
        end

        if unused_routes_errors.present?
          verb_width, path_width = widths
          buffer << "  No controller and action matches to the routes below"
          buffer << unused_routes_errors.map { |w| "    #{w.verb.ljust(verb_width)} #{w.path.ljust(path_width)} #{w.reqs}" }
        end

        ["[Route Mechanic]", buffer].join("\n") + "\n"
      end

      private

      def widths
        [
          unused_routes_errors.map { |w| w.verb.length }.max || 0,
          unused_routes_errors.map { |w| w.path.length }.max || 0
        ]
      end
    end
  end
end
