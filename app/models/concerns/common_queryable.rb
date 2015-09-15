module CommonQueryable
  extend ActiveSupport::Concern

  # Scope
  included do
    scope :finance, -> { where("stocks.category = '金融保險業'") }
    scope :exclude_finance, -> { where("stocks.category != '金融保險業'") }
  end

  # Define class methods here
  module ClassMethods
  end
end
