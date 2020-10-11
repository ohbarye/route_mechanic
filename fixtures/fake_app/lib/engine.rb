module FakeEngine
  class Engine < ::Rails::Engine
    isolate_namespace FakeEngine
  end
end

FakeEngine::Engine.routes.draw do
  resources :fakes do
    get 'hello', to: :hello
  end
end

module FakeEngine
  class ApplicationController < ActionController::Base; end
end

module FakeEngine
  class FakesController < ApplicationController
    def hello; end
  end
end
