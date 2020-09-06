require "delegate"

module RouteMechanic
  module Testing
    # This class just wraps ActionDispatch::Journey::Route
    class RouteWrapper < SimpleDelegator
      def endpoint
        app.dispatcher? ? "#{controller}##{action}" : app.rack_app.inspect
      end

      def path
        super.spec.to_s
      end

      def reqs
        @reqs ||= begin
                    reqs = endpoint
                    reqs += " #{requirements.except(:controller, :action)}" unless requirements.except(:controller, :action).empty?
                    reqs
                  end
      end

      def controller
        parts.include?(:controller) ? ":controller" : requirements[:controller]
      end

      def action
        parts.include?(:action) ? ":action" : requirements[:action]
      end

      def internal?
        internal
      end
    end
  end
end
