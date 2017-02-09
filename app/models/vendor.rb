class Vendor < ActiveRecord::Base
  #
  ## Validation
  #
  validates :name, presence: true
  #
  ## Scopes
  #
  scope :query, -> (q) { where('name LIKE ?', "%#{q.squish}%") }
  #
  ## Listings
  #
  def self.index
    all.order(:name)
  end

  def self.search(q)
    query(q).order(:name)
  end

  def self.controller_params
    [ :name ]
  end
end
