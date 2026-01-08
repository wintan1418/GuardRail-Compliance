class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /users/sign_up
  def new
    build_resource({})
    @organization = Organization.new
    yield resource if block_given?
    respond_with resource
  end

  # POST /users
  def create
    # Build organization first
    @organization = Organization.new(organization_params)

    if @organization.valid?
      ActiveRecord::Base.transaction do
        @organization.save!
        
        # Build user with organization
        build_resource(sign_up_params.merge(organization: @organization, role: 'owner'))
        
        resource.save!
        
        # Create trial subscription
        starter_plan = Plan.find_or_create_by!(name: 'Starter') do |plan|
          plan.stripe_price_id = 'price_starter_placeholder'
          plan.price_cents = 4900
          plan.interval = 'month'
          plan.max_users = 5
          plan.max_documents = 50
          plan.sms_enabled = false
          plan.slack_enabled = false
        end

        @organization.create_subscription!(
          plan: starter_plan,
          status: 'trialing',
          trial_ends_at: 14.days.from_now
        )

        # Log the signup
        AuditLog.log(
          organization: @organization,
          user: resource,
          action: 'user_joined',
          metadata: { signup: true, role: 'owner' }
        )

        if resource.persisted?
          if resource.active_for_authentication?
            set_flash_message! :notice, :signed_up
            sign_up(resource_name, resource)
            respond_with resource, location: after_sign_up_path_for(resource)
          else
            set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
            expire_data_after_sign_in!
            respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        else
          raise ActiveRecord::Rollback
        end
      end
    else
      build_resource(sign_up_params)
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  rescue ActiveRecord::RecordInvalid => e
    build_resource(sign_up_params)
    resource.errors.add(:base, e.message)
    clean_up_passwords resource
    set_minimum_password_length
    respond_with resource
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
  end

  def after_sign_up_path_for(resource)
    dashboard_path
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :industry)
  end
end
