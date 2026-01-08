# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    belongs_to_organization? && (user.admin? || record == user)
  end

  def create?
    user.admin? # Only admins can invite users
  end

  def update?
    belongs_to_organization? && (user.admin? || record == user)
  end

  def destroy?
    belongs_to_organization? && user.owner? && record != user
  end

  def invite?
    create?
  end

  private

  def belongs_to_organization?
    record.organization_id == user.organization_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(organization_id: user.organization_id)
    end
  end
end
