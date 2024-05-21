require 'test_helper'
require 'fake_app/rails_app'

class AssertNoUnusedActionsTest < Minitest::Test
  include RouteMechanic::Testing::Methods

  def test_that_fake_app_has_correct_routes
    with_routing do |set|
      set.draw do
        resources :users, only: %i[create update] do
          get :unknown
        end

        get 'computer_business', to: 'api#computer_business'
      end
      assert_no_unused_actions
    end
  end

  def test_that_fake_app_has_broken_routes
    e = assert_raises(Minitest::Assertion) do
      with_routing do |set|
        set.draw do
          resources :users
        end
        assert_no_unused_actions
      end
    end

    expected_message = <<~MSG
      [Route Mechanic]
        No route matches to the controllers and action methods below
          ApiController#computer_business
          UsersController#unknown
    MSG

    assert_equal expected_message, e.message
  end

  def test_that_fake_app_has_missing_routes
    e = assert_raises(Minitest::Assertion) do
      assert_no_unused_actions
    end

    expected_message = <<~MSG
      [Route Mechanic]
        No route matches to the controllers and action methods below
          UsersController#unknown
    MSG

    assert_equal expected_message, e.message
  end
end
