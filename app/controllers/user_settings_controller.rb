class UserSettingsController < ApplicationController
  require_authentication!

  def update
    @user = User.includes(:settings).find_by(login: params.require(:id))
    authorize @user.settings

    data = {
      settings_attributes: params.permit(
        :daily_email_enabled,
        :weekly_email_enabled,
        :newsletter_enabled,
        :snooze_until
      )
    }

    if @user.update_attributes(data)
      flash[:notice] = 'Thanks, your settings have been updated.'
    else
      flash[:alert] = "Sorry, we did not quite get that. #{@user.errors.full_messages.to_sentence}."
    end

    @collection = [@user.settings]
    render partial: 'flashes'
    flash.clear
  end
end
