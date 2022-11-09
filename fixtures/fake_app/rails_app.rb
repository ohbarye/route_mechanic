require 'rails/application'
require "action_controller/railtie"

require_relative './lib/engine'

FakeApp = Class.new(Rails::Application)
FakeApp.config.eager_load = false
FakeApp.config.hosts << 'www.example.com' if FakeApp.config.respond_to?(:hosts)
FakeApp.config.root = File.dirname(__FILE__)
FakeApp.initialize!

FakeApp.routes.draw do
  constraints subdomain: /\A[0-9a-z-]+\z/ do
    get '/constraints_test' => 'users#index'
  end

  scope ':locale', locale: /en|ja/ do
    get '/locale_test', to: 'photos#index'
    get '/photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
  end

  get 'organizations/:id', to: 'organizations#show', id: /[A-Z]\d{5}/

  get 'computer_business', to: 'api#computer_business'

  resources :users do
    get 'friends', to: :friends
    mount FakeEngine::Engine, at: "/fake_engine", fake_default_param: 'FAKE'
    post 'create_as_another_name', to: 'users#create'
  end
end
