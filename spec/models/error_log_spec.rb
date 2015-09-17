# == Schema Information
#
# Table name: error_logs
#
#  id         :integer          not null, primary key
#  data       :jsonb            default({}), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ErrorLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
