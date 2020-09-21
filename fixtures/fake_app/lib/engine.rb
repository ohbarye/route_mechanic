module FakeEngine
  class Engine < ::Rails::Engine
    isolate_namespace FakeEngine
  end
end
