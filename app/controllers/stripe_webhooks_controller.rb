class StripeWebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event.data.object)
    when 'customer.subscription.created'
      handle_subscription_created(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.paid'
      handle_invoice_paid(event.data.object)
    when 'invoice.payment_failed'
      handle_payment_failed(event.data.object)
    end

    render json: { received: true }, status: 200
  end

  private

  def handle_checkout_completed(session)
    organization = Organization.find_by(stripe_customer_id: session.customer)
    return unless organization

    subscription = organization.subscription
    return unless subscription

    subscription.update!(
      stripe_subscription_id: session.subscription,
      status: 'active'
    )

    AuditLog.log(
      organization: organization,
      action: 'subscription_activated',
      metadata: { plan: subscription.plan.name }
    )
  end

  def handle_subscription_created(stripe_subscription)
    organization = Organization.find_by(stripe_customer_id: stripe_subscription.customer)
    return unless organization

    plan = Plan.find_by(stripe_price_id: stripe_subscription.items.data.first.price.id)
    return unless plan

    subscription = organization.subscription || organization.build_subscription
    subscription.update!(
      plan: plan,
      stripe_subscription_id: stripe_subscription.id,
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )
  end

  def handle_subscription_updated(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    plan = Plan.find_by(stripe_price_id: stripe_subscription.items.data.first.price.id)
    
    subscription.update!(
      plan: plan || subscription.plan,
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )

    if stripe_subscription.cancel_at_period_end
      subscription.update!(canceled_at: Time.current)
    end
  end

  def handle_subscription_deleted(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(status: 'canceled', canceled_at: Time.current)

    AuditLog.log(
      organization: subscription.organization,
      action: 'subscription_canceled'
    )
  end

  def handle_invoice_paid(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: 'active') if subscription.status == 'past_due'
  end

  def handle_payment_failed(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: 'past_due')

    # TODO: Send notification to organization owner
  end
end
