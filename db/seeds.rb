# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding plans..."

# Create Subscription Plans
plans = [
  {
    name: 'Starter',
    description: 'Perfect for solo practitioners and small offices',
    stripe_price_id: 'price_starter_monthly', # Replace with actual Stripe price ID
    price_cents: 4900,
    interval: 'month',
    max_users: 3,
    max_documents: 50,
    features: ['email_reminders', 'audit_reports', 'document_storage'],
    active: true
  },
  {
    name: 'Professional',
    description: 'Best for growing practices with more team members',
    stripe_price_id: 'price_professional_monthly', # Replace with actual Stripe price ID
    price_cents: 9900,
    interval: 'month',
    max_users: 10,
    max_documents: 200,
    features: ['email_reminders', 'sms_reminders', 'audit_reports', 'document_storage', 'priority_support'],
    active: true
  },
  {
    name: 'Enterprise',
    description: 'For large practices with advanced compliance needs',
    stripe_price_id: 'price_enterprise_monthly', # Replace with actual Stripe price ID
    price_cents: 19900,
    interval: 'month',
    max_users: nil, # Unlimited
    max_documents: nil, # Unlimited
    features: ['email_reminders', 'sms_reminders', 'slack_integration', 'audit_reports', 'document_storage', 'priority_support', 'dedicated_account_manager'],
    active: true
  }
]

plans.each do |plan_attrs|
  Plan.find_or_create_by!(name: plan_attrs[:name]) do |plan|
    plan.description = plan_attrs[:description]
    plan.stripe_price_id = plan_attrs[:stripe_price_id]
    plan.price_cents = plan_attrs[:price_cents]
    plan.interval = plan_attrs[:interval]
    plan.max_users = plan_attrs[:max_users]
    plan.max_documents = plan_attrs[:max_documents]
    plan.features = plan_attrs[:features]
    plan.active = plan_attrs[:active]
  end
end

puts "Created #{Plan.count} plans"

puts "Seeding default compliance categories..."

default_categories = [
  { name: 'HIPAA', color: '#3B82F6', icon: 'shield' },
  { name: 'Licenses', color: '#10B981', icon: 'badge' },
  { name: 'Certifications', color: '#8B5CF6', icon: 'certificate' },
  { name: 'Policies', color: '#F59E0B', icon: 'document' },
  { name: 'Training', color: '#EC4899', icon: 'academic' },
  { name: 'Insurance', color: '#06B6D4', icon: 'umbrella' }
]

# Note: Categories are created per-organization, so this is just for reference
puts "Default categories defined: #{default_categories.map { |c| c[:name] }.join(', ')}"

puts "Seed complete!"
