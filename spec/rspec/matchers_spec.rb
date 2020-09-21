require 'fake_app/rails_app'

RSpec.describe RouteMechanic::RSpec::Matchers, type: :routing do
  include RouteMechanic::RSpec::Matchers

  it "fails if application does not have valid routes" do
    expect {
      expect(Rails.application).to have_valid_routes
    }.to raise_error(<<~MSG)
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

  it "provides a description" do
    expect(have_valid_routes.description).to eq "have valid routes"
  end
end
