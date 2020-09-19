# RouteMechanic
[![Gem Version](https://badge.fury.io/rb/route_mechanic.svg)](https://badge.fury.io/rb/route_mechanic)
[![Build Status](https://github.com/ohbarye/route_mechanic/workflows/test/badge.svg?branch=master)](https://github.com/ohbarye/route_mechanic/actions?query=workflow%3Atest)

No need to maintain Rails' routing tests manually. RouteMechanic automatically detects broken routes and missing action methods in controller once you've finished installation.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'route_mechanic'
end
```

And then execute:

```shell
$ bundle install
```

## Usage

RouteMechanic is available for both RSpec and MiniTest.

All you have to do is to add just one test case that keeps your application's routes not broken.

### RSpec

Just add a test file which has only one test case using `have_valid_routes` matcher.

```ruby
RSpec.describe 'Rails.application', type: :routing do
  it "fails if application does not have valid routes" do
   expect(Rails.application).to have_valid_routes
  end
end
```

### MiniTest

Just add a test file like below.

```ruby
class RoutingTest < Minitest::Test
  include ::RouteMechanic::Testing::Methods

  def test_that_application_has_correct_routes
    assert_all_routes
  end
end
```

### What if RouteMechanic detects broken routes?

It tells you broken routes as follows.

```ruby
  0) Rail.application fails if application does not have valid routes
     Failure/Error: expect(Rails.application.routes).to have_valid_routes

       [Route Mechanic]
         No route matches to the controllers and action methods below
           UsersController#unknown
         No controller and action matches to the routes below
           GET    /users/:user_id/friends(.:format) users#friends
           GET    /users(.:format)                  users#index
           DELETE /users/:id(.:format)              users#destroy
     # ./spec/rspec/matchers_spec.rb:8:in `block (2 levels) in <top (required)>'

1 examples, 1 failure, 0 passed
```

RouteMechanic reports 2 types of broken routes.

1. Missing routes
    - Your application has the controller and the action method but `config/routes.rb` doesn't have corresponds settings.
2. Missing action methods
    - Your application's `config/routes.rb` has routing declaration but no controller has a correspond action method.

## Motivation

I believe most Rails developers write request specs instead of routing specs, and you might wonder what's worth to automate routing spec. Having said that, I can come up with some use-cases of this gem.

1. When your project is kinda aged and none knows which route is alive and which one is dead.
    - => You can detect dead code by using this gem.
2. When your application doesn't have enough request specs (even controller specs).
    - => This gem could be a good start point to increase tests to ensure routing is valid.
3. When you try to make big refactor of `config/routes.rb`.
    - => It's burden to run all request specs during refactoring. This could save your time.
4. When you're compelled to write routing specs by any pressure. ;-)
    - => Set you free from tedious work!


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RouteMechanic project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/route_mechanic/blob/master/CODE_OF_CONDUCT.md).
