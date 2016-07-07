class OrganisationUsersController < ApplicationController
  require_authentication!

  def update
    @user =     User.find_by(login: params.require(:id))
    @org =      Organisation.find_by(name: params.require(:organisation_id))
    @org_user = OrganisationUser.find_by(organisation_id: @org.id, user_id: @user.id)

    authorize @org_user

    data = params.require(:organisation_user).permit(:email)

    if @org_user.update_attributes(data)
      flash[:notice] = 'Saved!'
    else
      flash[:alert] = 'Oops...'
    end

    # binding.pry

    if request.xhr?
      render partial: 'shared/loner', collection: [
        { partial: 'flashes' },
        { partial: 'organisation_users/form', locals: { organisation_user: @org_user } },
      ]
      flash.clear
    else
      redirect_to :back
    end
  end
end
