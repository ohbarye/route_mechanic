require "test_helper"
require 'fake_app/rails_app'

class AssertAllRoutesTest < Minitest::Test
  include RouteMechanic::Testing::Methods

  def test_that_fake_app_has_correct_routes
    with_routing do |set|
      set.draw do
        resources :users, only: %i[create update] do
          get :unknown
        end
        get 'computer_business', to: 'api#computer_business'
      end
      assert_all_routes
    end
  end

  def test_that_fake_app_has_broken_routes
    e = assert_raises(Minitest::Assertion) do
      with_routing do |set|
        set.draw do
          resources :users
        end
        assert_all_routes
      end
    end

    expected_message = <<~MSG
      [Route Mechanic]
        No route matches to the controllers and action methods below
          UsersController#unknown
          ApiController#computer_business
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
      assert_all_routes
    end

    expected_message = <<~MSG
      [Route Mechanic]
        No route matches to the controllers and action methods below
          UsersController#unknown
        No controller and action matches to the routes below
          GET    /constraints_test(.:format)       users#index
          GET    /:locale/locale_test(.:format)    photos#index {:locale=>/en|ja/}
          GET    /:locale/photos/:id(.:format)     photos#show {:locale=>/en|ja/, :id=>/[A-Z]\\d{5}/}
          GET    /organizations/:id(.:format)      organizations#show {:id=>/[A-Z]\\d{5}/}
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
