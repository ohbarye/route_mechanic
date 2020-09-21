require 'fake_app/rails_app'

RSpec.describe RouteMechanic::Testing::Methods do
  include RouteMechanic::Testing::Methods

  it "detects missing routes and missing action methods" do
    begin
      assert_all_routes
    rescue Minitest::Assertion => e
      expect(e.message).to eq <<~MSG
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
    end
  end

  it "passes when missing routes and missing action methods don't exist" do
    with_routing do |set|
      set.draw do
        resources :users, only: %i[create update] do
          get :unknown
        end
      end
      expect { assert_all_routes }.not_to raise_error
    end
  end
end
