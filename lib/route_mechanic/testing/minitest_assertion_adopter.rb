require "minitest/assertions"

module RouteMechanic
  module Testing
    module Methods
      # @private
      module MinitestCounters
        attr_writer :assertions
        def assertions
          @assertions ||= 0
        end
      end

      module MinitestAssertionAdapter
        include Minitest::Assertions
        include MinitestCounters
      end
    end
  end
end
