class HomepageController < ApplicationController
  def show
    if current_user
      @jobs = JobStats.where(actor: current_user)
    end
  end
end
