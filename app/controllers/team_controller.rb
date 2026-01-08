class TeamController < ApplicationController
  before_action :set_user, only: [:show, :destroy, :resend_invitation]
  before_action :authorize_admin, only: [:invite, :destroy]

  def index
    @team_members = policy_scope(User).includes(:organization).order(:role, :first_name)
    @pending_invitations = [] # Placeholder for invitations system
  end

  def show
    authorize @user
    @uploaded_documents = @user.uploaded_documents.order(created_at: :desc).limit(10)
    @assigned_documents = @user.assigned_documents.order(:expiration_date).limit(10)
  end

  def invite
    # Placeholder for invitation system
    redirect_to team_index_path, notice: 'Invitation system coming soon.'
  end

  def destroy
    authorize @user
    
    if @user == current_user
      redirect_to team_index_path, alert: 'You cannot remove yourself.'
      return
    end

    if @user.owner?
      redirect_to team_index_path, alert: 'Cannot remove the organization owner.'
      return
    end

    @user.destroy
    
    AuditLog.log(
      organization: current_organization,
      user: current_user,
      action: 'user_removed',
      metadata: { removed_user: @user.full_name }
    )
    
    redirect_to team_index_path, notice: "#{@user.full_name} has been removed from the team."
  end

  def resend_invitation
    # Placeholder for invitation system
    redirect_to team_index_path, notice: 'Invitation resent.'
  end

  private

  def set_user
    @user = current_organization.users.find(params[:id])
  end

  def authorize_admin
    unless current_user.admin?
      redirect_to team_index_path, alert: 'Only admins can perform this action.'
    end
  end
end
