module CommonQueryable
  extend ActiveSupport::Concern

  # Scope
  included do
    scope :finance, -> { where("stocks.category = '金融保險業'") }
    scope :exclude_finance, -> { where("stocks.category != '金融保險業'") }
    scope :only, -> (category = nil) { where("stocks.category = ?", category) if category }
    scope :exclude, -> (category = nil) { where("stocks.category != ?", category) if category }
  end

  # Define class methods here
  class_methods do
  end
end
