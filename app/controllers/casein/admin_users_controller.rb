require 'securerandom'

module Casein
  class AdminUsersController < Casein::CaseinController

    before_filter :needs_admin, :except => [:show, :destroy, :update, :update_password]
    before_filter :needs_admin_or_current_user, :only => [:show, :destroy, :update, :update_password]

    def index
      @casein_page_title = I18n.t("controllers.users.users")
      @users = Casein::AdminUser.order(sort_order(:login)).paginate :page => params[:page]
    end

    def new
      @casein_page_title = I18n.t("controllers.users.add")
    	@casein_admin_user = Casein::AdminUser.new
    	@casein_admin_user.time_zone = Rails.configuration.time_zone
    end

    def create

      generate_random_password if params[:generate_random_password]

      @casein_admin_user = Casein::AdminUser.new casein_admin_user_params

      if @casein_admin_user.save
        flash[:notice] = I18n.t("controllers.users.email_sent", :name => @casein_admin_user.name)
        redirect_to casein_admin_users_path
      else
        flash.now[:warning] = I18n.t("controllers.users.create_error")
        render :action => :new
      end
    end

    def show
    	@casein_admin_user = Casein::AdminUser.find params[:id]
    	@casein_page_title = @casein_admin_user.name + I18n.t("controllers.users.view")
    end

    def update
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + I18n.t("controllers.users.update")

      if @casein_admin_user.update_attributes casein_admin_user_params
        flash[:notice] = I18n.t("controllers.users.updated", :name => @casein_admin_user.name)
      else
        flash.now[:warning] = I18n.t("controllers.users.update_error")
        render :action => :show
        return
      end

      if @session_user.is_admin?
        redirect_to casein_admin_users_path
      else
        redirect_to :controller => :casein, :action => :index
      end
    end

    def update_password
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + I18n.t("controllers.users.update_password")

      if @casein_admin_user.valid_password? params[:form_current_password]
        if params[:casein_admin_user][:password].blank? && params[:casein_admin_user][:password_confirmation].blank?
          flash[:warning] = I18n.t("controllers.users.blank_password")
        elsif @casein_admin_user.update_attributes casein_admin_user_params
          flash[:notice] = I18n.t("controllers.users.password_changed")
        else
          flash[:warning] = I18n.t("controllers.users.password_update_problems")
        end
      else
        flash[:warning] = I18n.t("controllers.users.password_incorrect")
      end

      redirect_to :action => :show
    end

    def reset_password
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + I18n.t("controllers.users.reset_password")

      if params[:generate_random_password].blank? && params[:casein_admin_user][:password].blank? && params[:casein_admin_user][:password_confirmation].blank?
        flash[:warning] = I18n.t("controllers.users.blank_password")
      else
        generate_random_password if params[:generate_random_password]
        @casein_admin_user.notify_of_new_password = true unless (@casein_admin_user.id == @session_user.id && params[:generate_random_password].blank?)

        if @casein_admin_user.update_attributes casein_admin_user_params
          unless @casein_admin_user.notify_of_new_password
            flash[:notice] = I18n.t("controllers.users.password_reset")
          else
            flash[:notice] = I18n.t("controllers.users.password_reset_for", :name => @casein_admin_user.name)
          end
        else
          flash[:warning] = I18n.t("controllers.users.password_reset_problems")
        end
      end

      redirect_to :action => :show
    end

    def destroy
      user = Casein::AdminUser.find params[:id]
      if user.is_admin? == false || Casein::AdminUser.has_more_than_one_admin
        user.destroy
        flash[:notice] = I18n.t("controllers.users.deleted", :name => @casein_admin_user.name)
      end
      redirect_to casein_admin_users_path
    end

    private

      def generate_random_password
        random_password = random_string = SecureRandom.hex
        params[:casein_admin_user] = Hash.new if params[:casein_admin_user].blank?
        params[:casein_admin_user].merge! ({:password => random_password, :password_confirmation => random_password})
      end

      def casein_admin_user_params
        params.require(:casein_admin_user).permit(:login, :name, :email, :time_zone, :access_level, :password, :password_confirmation)
      end

  end
end
