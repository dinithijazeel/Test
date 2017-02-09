#
# Opportunity
#
class Opportunity < ActiveRecord::Base
  #
  # Associations
  belongs_to :contact

  def self.controller_params
    [ :need,
      :budget,
      :timing,
      :decision_maker,
      :competition,
      :contact_id ]    
  end
end
