require "test_helper"
require 'fake_app/rails_app'

class RouteMechanicTestingMethodsTest < Minitest::Test
  include RouteMechanic::Testing::Methods

  def user_routes
    FakeApp.routes
  end

  def test_that_fake_app_has_correct_routes
    with_routing do |set|
      set.draw do
        resources :users, only: %i[create update] do
          get :unknown
        end
      end
      assert_route_conforms
    end
  end

  def test_that_fake_app_has_broken_routes
    e = assert_raises(Minitest::Assertion) do
      with_routing do |set|
        set.draw do
          resources :users
        end
        assert_route_conforms
      end
    end

    expected_message = <<~MSG
      [Route Mechanic]
        No route matches to the controllers and action methods below
          UsersController#unknown
        No controller and action matches to the routes below
          GET    /users(.:format)          users#index
          GET    /users/new(.:format)      users#new
          GET    /users/:id/edit(.:format) users#edit
          GET    /users/:id(.:format)      users#show
          DELETE /users/:id(.:format)      users#destroy

    MSG

    assert_equal expected_message, e.message
  end

  def test_that_fake_app_has_missing_routes
    e = assert_raises(Minitest::Assertion) do
      assert_route_conforms
    end

    expected_message = <<~MSG
      [Route Mechanic]
        No route matches to the controllers and action methods below
          UsersController#unknown
        No controller and action matches to the routes below
          GET    /users/:user_id/friends(.:format) users#friends
          GET    /users(.:format)                  users#index
          GET    /users/new(.:format)              users#new
          GET    /users/:id/edit(.:format)         users#edit
          GET    /users/:id(.:format)              users#show
          DELETE /users/:id(.:format)              users#destroy

    MSG

    assert_equal expected_message, e.message
  end
end
