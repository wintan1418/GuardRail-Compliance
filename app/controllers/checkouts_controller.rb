class CheckoutsController < ApplicationController
  before_action :authorize_owner

  def create
    plan = Plan.find(params[:plan_id])
    
    # Create or get Stripe customer
    if current_organization.stripe_customer_id.blank?
      customer = Stripe::Customer.create(
        email: current_user.email,
        name: current_organization.name,
        metadata: { organization_id: current_organization.id }
      )
      current_organization.update!(stripe_customer_id: customer.id)
    end

    # Create checkout session
    session = Stripe::Checkout::Session.create(
      customer: current_organization.stripe_customer_id,
      payment_method_types: ['card'],
      line_items: [{
        price: plan.stripe_price_id,
        quantity: 1
      }],
      mode: 'subscription',
      success_url: "#{root_url}settings/billing?success=true",
      cancel_url: "#{root_url}settings/billing?canceled=true",
      metadata: {
        organization_id: current_organization.id,
        plan_id: plan.id
      }
    )

    redirect_to session.url, allow_other_host: true
  end

  def billing_portal
    return redirect_to settings_billing_path, alert: 'No billing account found.' if current_organization.stripe_customer_id.blank?

    session = Stripe::BillingPortal::Session.create(
      customer: current_organization.stripe_customer_id,
      return_url: settings_billing_path
    )

    redirect_to session.url, allow_other_host: true
  end

  private

  def authorize_owner
    unless current_user.owner?
      redirect_to dashboard_path, alert: 'Only the organization owner can manage billing.'
    end
  end
end
