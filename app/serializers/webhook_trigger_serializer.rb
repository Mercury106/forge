class WebhookTriggerSerializer < ApplicationSerializer

  attributes :id, :user_id, :site_id, :event, :timestamp, :url, :http_method, :parameters

  def timestamp
    object.updated_at.strftime("%m/%d/%Y  %I:%M%p")
  end

  def event
    return "Deployment success" if object.event == "deploy_success"
    return "Deployment failure" if object.event == "deploy_failure"
    return "Form submission" if object.event == "form_submission"
  end

end