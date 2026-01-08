class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy, :download, :archive]

  def index
    @documents = policy_scope(Document)
      .includes(:compliance_category, :uploaded_by, :assigned_to)
      .order(created_at: :desc)

    # Filters
    @documents = @documents.where(status: params[:status]) if params[:status].present?
    @documents = @documents.where(compliance_category_id: params[:category]) if params[:category].present?
    @documents = @documents.where(assigned_to_id: params[:assigned_to]) if params[:assigned_to].present?
    
    if params[:search].present?
      @documents = @documents.where('name ILIKE ?', "%#{params[:search]}%")
    end

    @categories = current_organization.compliance_categories.ordered
    @team_members = current_organization.users.order(:first_name)
  end

  def show
    authorize @document
  end

  def new
    @document = current_organization.documents.build
    @document.uploaded_by = current_user
    authorize @document
    @categories = current_organization.compliance_categories.ordered
    @team_members = current_organization.users.order(:first_name)
  end

  def create
    @document = current_organization.documents.build(document_params)
    @document.uploaded_by = current_user
    authorize @document

    if @document.save
      AuditLog.log(
        organization: current_organization,
        user: current_user,
        action: 'document_uploaded',
        resource: @document,
        metadata: { name: @document.name }
      )
      redirect_to @document, notice: 'Document uploaded successfully.'
    else
      @categories = current_organization.compliance_categories.ordered
      @team_members = current_organization.users.order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @document
    @categories = current_organization.compliance_categories.ordered
    @team_members = current_organization.users.order(:first_name)
  end

  def update
    authorize @document

    if @document.update(document_params)
      AuditLog.log(
        organization: current_organization,
        user: current_user,
        action: 'document_updated',
        resource: @document
      )
      redirect_to @document, notice: 'Document updated successfully.'
    else
      @categories = current_organization.compliance_categories.ordered
      @team_members = current_organization.users.order(:first_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @document
    @document.destroy
    
    AuditLog.log(
      organization: current_organization,
      user: current_user,
      action: 'document_deleted',
      metadata: { name: @document.name }
    )
    
    redirect_to documents_path, notice: 'Document deleted successfully.'
  end

  def download
    authorize @document, :show?
    
    if @document.file.attached?
      redirect_to rails_blob_path(@document.file, disposition: 'attachment')
    else
      redirect_to @document, alert: 'No file attached to this document.'
    end
  end

  def archive
    authorize @document, :update?
    @document.update!(status: 'archived')
    redirect_to documents_path, notice: 'Document archived successfully.'
  end

  def expiring
    @documents = policy_scope(Document)
      .where.not(expiration_date: nil)
      .where('expiration_date <= ?', 60.days.from_now)
      .where('expiration_date > ?', Date.current)
      .order(:expiration_date)
  end

  private

  def set_document
    @document = current_organization.documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(
      :name, :description, :compliance_category_id, :assigned_to_id,
      :issue_date, :expiration_date, :document_type, :issuing_authority,
      :reference_number, :auto_remind, :file, reminder_days: []
    )
  end
end
