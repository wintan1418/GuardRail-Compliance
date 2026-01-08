class DashboardController < ApplicationController
  def show
    @organization = current_organization
    @health_score = @organization.compliance_health_score || @organization.calculate_health_score
    
    # Documents expiring in next 30 days
    @urgent_documents = current_organization.documents
      .where.not(expiration_date: nil)
      .where('expiration_date <= ?', 30.days.from_now)
      .order(:expiration_date)
      .limit(10)

    # Quick stats
    @total_documents = current_organization.documents.count
    @expiring_soon_count = current_organization.documents.expiring_soon.count
    @expired_count = current_organization.documents.expired.count
    @team_count = current_organization.users.count

    # Recent activity
    @recent_activity = current_organization.audit_logs.recent.limit(5)
  end
end
