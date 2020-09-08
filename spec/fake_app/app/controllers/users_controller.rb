class UsersController < ApplicationController
  def create
    render json: { id: 1 }
  end

  def update
    render json: { id: 1 }
  end

  def unknown; end
end
