class ServiceConfigParam < ActiveRecord::Base
  belongs_to :service

  validates :name, length: {minimum: 3, maximum: 64},
                   format: {without: /[^A-Z0-9_]/}
  validates :environment_slug, inclusion: {in: ServiceEnvironment.all_slugs.map(&:to_s)}

  def self.visible_to(user_or_user_id)
    user_id = user_or_user_id.is_a?(User) ? user_or_user_id.id : user_or_user_id
    joins(:service).where(services: {created_by_user_id: user_id})
  end
end
