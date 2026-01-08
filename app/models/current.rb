class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :organization
  attribute :request_id, :user_agent, :ip_address

  resets { Time.zone = nil }

  def user=(user)
    super
    self.organization = user&.organization
    Time.zone = user&.time_zone if user&.respond_to?(:time_zone)
  end
end
