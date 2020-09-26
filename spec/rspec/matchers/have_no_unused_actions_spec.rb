require 'fake_app/rails_app'

RSpec.describe RouteMechanic::RSpec::Matchers::HaveNoUnusedActions, type: :routing do
  include RouteMechanic::RSpec::Matchers

  it "fails if application has unused actions" do
    expect {
      expect(Rails.application).to have_no_unused_actions
    }.to raise_error(<<~MSG.chomp)
        [Route Mechanic]
          No route matches to the controllers and action methods below
            UsersController#unknown
    MSG
  end

  it "provides a description" do
    expect(have_no_unused_actions.description).to eq "have no unused actions"
  end
end
