module Casein
  class PasswordResetsController < Casein::CaseinController

    skip_before_filter :authorise
    before_filter :load_user_using_perishable_token, :only => [:edit, :update]

    layout 'casein_auth'

    def create
      users = Casein::AdminUser.where(:email => params[:recover_email]).all

      if users.length > 0
        users.each do |user|
          user.send_password_reset_instructions
        end

        if users.length > 1
          flash[:notice] = I18n.t("controllers.passwords.multiple_accounts", :email => params[:recover_email])
        else
          flash[:notice] = I18n.t("controllers.passwords.email_sent", :email => params[:recover_email])
        end
      else
        flash[:warning] = I18n.t("controllers.passwords.no_user")
      end

      redirect_to new_casein_admin_user_session_url
    end

    def edit
      render
    end

    def update

      if params[:casein_admin_user][:password].empty? || params[:casein_admin_user][:password_confirmation].empty?
        flash.now[:warning] = I18n.t("controllers.passwords.empty_field")
      else

        @reset_user.password = params[:casein_admin_user][:password]
        @reset_user.password_confirmation = params[:casein_admin_user][:password_confirmation]

        if @reset_user.save
          flash[:notice] = I18n.t("controllers.passwords.updated")
          redirect_to new_casein_admin_user_session_url
          return
        end
      end

      render :action => :edit
    end

  private

    def load_user_using_perishable_token

      @reset_user = Casein::AdminUser.find_using_perishable_token params[:token]

      unless @reset_user
        flash[:warning] = I18n.t("controllers.passwords.not_located")
        redirect_to new_casein_admin_user_session_url
      end
    end
  end
end
