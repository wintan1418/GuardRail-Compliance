# frozen_string_literal: true

class DocumentPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can list documents in their org
  end

  def show?
    belongs_to_organization?
  end

  def create?
    true # All users can upload documents
  end

  def update?
    belongs_to_organization? && (user.admin? || record.uploaded_by == user || record.assigned_to == user)
  end

  def destroy?
    belongs_to_organization? && user.admin?
  end

  def download?
    show?
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
