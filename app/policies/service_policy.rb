class ServicePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def new?
    user.present?
  end

  def edit?
    user.id == record.created_by_user_id
  end

  def create?
    user.id == record.created_by_user_id
  end
end
