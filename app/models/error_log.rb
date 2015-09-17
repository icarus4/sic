# == Schema Information
#
# Table name: error_logs
#
#  id         :integer          not null, primary key
#  data       :jsonb            default({}), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ErrorLog < ActiveRecord::Base
end
