class WebhookTriggersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_webhook_trigger, only: [:update, :destroy]

  def index
    render json: current_user.webhook_triggers
  end

  def create
    params = webhook_trigger_params

    params[:event] = "deploy_success"  if params[:event] == "Deployment success"
    params[:event] = "deploy_failure"  if params[:event] == "Deployment failure"
    params[:event] = "form_submission"  if params[:event] == "Form submission"

    wt = current_user.webhook_triggers.build(params)
    if wt.save
      render json: wt
    else
      render json: { errors: wt.errors.full_messages }, status: 422
    end
  end

  def update
    params = webhook_trigger_params

    params[:event] = "deploy_success"  if params[:event] == "Deployment success"
    params[:event] = "deploy_failure"  if params[:event] == "Deployment failure"
    params[:event] = "form_submission"  if params[:event] == "Form submission"

    @wt.assign_attributes(params)
    if @wt.save
      @wt[:event] = "deploy_success"  if @wt[:event] == "Deployment success"
      @wt[:event] = "deploy_failure"  if @wt[:event] == "Deployment failure"
      @wt[:event] = "form_submission"  if @wt[:event] == "Form submission"
      render json: @wt

    else
      render json: { errors: @wt.errors.full_messages }, status: 422
    end
    @wt.restore_attributes
  end

  def destroy
    if @wt.destroy
      head :ok
    else
      render json: { errors: @wt.errors.full_messages }, status: 422
    end
  end

  private

  def find_webhook_trigger
    @wt = current_user.webhook_triggers.find(params[:id])
    if @wt.blank?
      render json: { errors: ['Webhook Trigger not found'] }
      return
    end
  end

  def webhook_trigger_params
    params.require(:webhook_trigger).permit(:site_id, :event, :url, :http_method, :parameters)
  end
end