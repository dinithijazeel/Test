class User < ActiveRecord::Base
  #
  ## Behavior
  #
  acts_as_paranoid
  devise :database_authenticatable,
         # :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable
  #
  ## Scopes
  #
  scope :query, -> (q) { where('first_name LIKE ? OR last_name LIKE ? OR nickname LIKE ? OR email LIKE ?', "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%", "%#{q.squish}%") }
  #
  ## Listings
  #
  def self.index
    all.with_deleted.order('current_sign_in_at DESC')
  end

  def self.search(q)
    query(q).order(:last_name, :email)
  end
  #
  ## Helpers
  #
  def identifier
    if !(nickname.nil? || nickname.empty?)
      return nickname
    elsif !(first_name.nil? || first_name.empty?) && !(last_name.nil? || last_name.empty?)
      return "#{first_name} #{last_name}"
    else
      return email
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # Roles + Authorization

  def is(check_role)
    if role.nil?
      false
    else
      role <= Rails.configuration.x.users.roles[check_role]
    end
  end

  def self.roles
    roles_list = Rails.configuration.x.users.roles.clone
    unless User.current.is(:root)
      roles_list.delete(:root)
    end
    roles_list
  end

  def role_name
    Rails.configuration.x.users.roles.key(role).to_s
  end

  # Model access

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  # Controller parameters

  def self.controller_profile_params
    [ :first_name,
      :last_name,
      :phone,
      :nickname,
      :about ]    
  end
end
