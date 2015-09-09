class ActiveSupport::TimeWithZone
  # ==== Description
  # Get current qurter
  # ==== Usage example
  # Time.zone.now.quarter
  def quarter
    (month - 1) / 3 + 1
  end
end
