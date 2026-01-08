class UpdateDocumentStatusJob < ApplicationJob
  queue_as :default

  def perform
    # Update all documents with expiration dates
    Document.where.not(expiration_date: nil).find_each do |doc|
      doc.update_status!
    end

    Rails.logger.info "Updated document statuses for all organizations"
  end
end
