class ApplicationController < ActionController::Base
  protect_from_forgery

     # def logout
      # # optionally do some local cleanup here
      # CASClient::Frameworks::Rails::Filter.logout(self)
      # redirect_to root_path
    # end
end
