module Casein

  class CaseinNotification < ActionMailer::Base

  	self.prepend_view_path File.join(File.dirname(__FILE__), '..', 'views', 'casein')

  	def generate_new_password from, casein_admin_user, host, pass
  		@name = casein_admin_user.name
  		@host = host
  		@login = casein_admin_user.login
  		@pass = pass
  		@from_text = casein_config_website_name

  		mail(:to => casein_admin_user.email, :from => from, :subject => I18n.t("mailers.casein.new_password.title", :website_name => casein_config_website_name))
  	end

  	def new_user_information from, casein_admin_user, host, pass
      @name = casein_admin_user.name
  		@host = host
  		@login = casein_admin_user.login
  		@pass = pass
  		@from_text = casein_config_website_name

  		mail(:to => casein_admin_user.email, :from => from, :subject => I18n.t("mailers.casein.new_user_account.title", :website_name => casein_config_website_name))
  	end

  	def password_reset_instructions from, casein_admin_user, host
  	  ActionMailer::Base.default_url_options[:host] = host.gsub("http://", "")
      @name = casein_admin_user.name
      @host = host
      @login = casein_admin_user.login
      @reset_password_url = edit_casein_password_reset_url + "/?token=#{casein_admin_user.perishable_token}"
      @from_text = casein_config_website_name

      mail(:to => casein_admin_user.email, :from => from, :subject => I18n.t("mailers.casein.password_reset.title", :website_name => casein_config_website_name))
    end

  end
end
