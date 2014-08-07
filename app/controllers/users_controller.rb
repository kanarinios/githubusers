class UsersController < ApplicationController
  def index
  end

  def create
    @user = User.new
    GithubUserWorker.perform_async("dawidw")
  end

end
