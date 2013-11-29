# -*- coding: utf-8 -*-
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::StrongParameters
  include PublicActivity::StoreController

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) 
    devise_parameter_sanitizer.for(:sign_in) 
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :avatar, :password, :password_confirmation, :current_password) }
  end

  private
  
  # cookie가 아닌 auth token을 이용한 authentication
  # X-Auth-Email : 메일
  # X-Auth-Token : 토큰
  # 개발일 경우는 Token 체크 안하고 인증 허용
   def authenticate_user_from_token!
     user_email = request.headers["X-Auth-Email"].presence
     user       = user_email && User.find_by_email(user_email)

    if ENV["RAILS_ENV"] == "development" 
      sign_in user, store: false if user
    else
      if user && Devise.secure_compare(user.authentication_token, request.headers["X-Auth-Token"])
        sign_in user, store: false
      end
    end
   end
end
