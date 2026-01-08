class UpdateHealthScoresJob < ApplicationJob
  queue_as :default

  def perform
    Organization.find_each do |org|
      org.update_health_score!
    end

    Rails.logger.info "Updated health scores for all organizations"
  end
end
