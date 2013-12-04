class Users::SessionsController < Devise::SessionsController
  before_filter :authenticate_user!, :except => [:create]
  respond_to :json

  def create

    if !params[:email].nil? && !params[:password].nil?
      resource = User.find_for_database_authentication(:email => params[:email])
      invalid_login_attempt unless resource.valid_password? params[:password]
    elsif !params[:access_token].nil? && !params[:provider].nil?      
      resource = User.from_authinfo userinfo_from_auth_service(params[:provider], params[:access_token])      
    else
      invalid_login_attempt
    end

    sign_in(:user, resource)
    resource.ensure_authentication_token
    render :json => {
      :success => true, 
      :auth_token => resource.authentication_token, 
      :email => resource.email, 
      :username => resource.username, 
      :id => resource.id,
      :avatar_url => {
        :original => resource.avatar.url,
        :medium   => resource.avatar.url(:medium),
        :thumb    => resource.avatar.url(:thumb)
      },
      :provider => params[:provider]
    }    
        
  end

  def destroy
    current_user.authentication_token = nil;
    current_user.save
    sign_out :user

    render :json=> {:success=>true}
  end


  protected

  def invalid_login_attempt
    render :json=> {:success=>false, :message=>"Error with your email or password"}, :status=>401
  end

  private

  def userinfo_from_auth_service(provider, access_token)
    authinfo = {}
    case provider
    when 'facebook'
      fb_session = MiniFB::OAuthSession.new(params[:access_token], 'es_ES')      
      
      authinfo[:provider] = 'facebook'
      authinfo[:email] = "#{fb_session.me.username}@facebook.com" #fb_session.me.email
      authinfo[:username] = fb_session.me.username
      authinfo[:uid] = fb_session.me.id
      authinfo[:picture_url] = "https://graph.facebook.com/#{fb_session.me.id}/picture?type=large&access_token=#{access_token}"
    end
    authinfo
  end
  
end