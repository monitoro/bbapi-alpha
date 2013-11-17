class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  has_many :group_members, foreign_key: :member_id, dependent: :destroy
  has_many :membered_groups, class_name: 'Group', through: :group_members, source: :group
  has_many :created_groups, class_name: 'Group', foreign_key: :owner_id, dependent: :nullify         
  has_many :categories, foreign_key: :owner_id, dependent: :nullify
  has_many :bookkeepings_issued_by_me, class_name: 'Bookkeeping', foreign_key: 'issuer_id'
  has_many :bookkeepings_written_by_me, class_name: 'Bookkeeping', foreign_key: 'writer_id'
  has_many :authorizations
  has_many :proofs, dependent: :destroy
  has_many :comments, foreign_key: 'writer_id'

  # to declare associations for 'like' functionality
  has_many :likes, dependent: :destroy
  has_many :like_bookkeepings, class_name: 'Bookkeeping', through: :likes,
           source: :likeable, source_type: 'Bookkeeping'  

  has_attached_file :avatar, 
                    :styles => { :medium => "300x300#", :thumb => "100x100#" }, 
                    :default_url => "/images/default/:style_avatar.png",
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :bucket => 'rorlab';                            

  before_save :ensure_authentication_token
  
  # token_authenticable is deprecated
  # https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  
  def self.from_omniauth(auth, signed_in_resource=nil)    
    user = find_or_create_by(email: authinfo.email) do |user|                  
      # Authorization.create(provider: auth[:provider], uid: auth[:uid], user_id: user.id)        
      # user.name = auth.info.nickname
      user.password = Devise.friendly_token[0,20]       
    end    
    Authorization.find_or_create_by(provider: auth[:provider], uid: auth[:uid], user: user)
    user
  end

  def self.from_authinfo(authinfo)
    user = find_or_create_by(email: authinfo[:email]) do |user|
      user.password = Devise.friendly_token[0,20]
    end
    Authorization.find_or_create_by(provider: authinfo[:provider], uid: authinfo[:uid], user: user)
    user
  end

  def activities(limit = 30)
    PublicActivity::Activity.where(:recipient_type => "Group", :recipient_id => membered_groups_id).order("created_at desc").limit(limit)
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
 
  private

  def membered_groups_id
    membered_groups.map {|group| group.id} 
  end
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

end
