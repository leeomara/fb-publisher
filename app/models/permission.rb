class Permission < ActiveRecord::Base
  belongs_to :team
  belongs_to :service
end
