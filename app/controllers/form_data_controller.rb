class FormDataController < ApplicationController
  before_filter :authenticate_user!, except: [:create, :cors]
  before_filter :set_cors_headers, only: [:create, :cors]

  def create
    url = URI.parse(request.referer).host
    url = 'aaa-258.getforge.io' if url == 'localhost'
    site = Site.find_by(url: [url, "www.#{url}", url.gsub(/\Awww\./, '')])
    if site.blank?
      render json: { errors: ['This site is unavailable'] }, status: 422
      return
    end

    form_scope = params.fetch('forge_form_name').parameterize.underscore
    if form_scope.blank?
      render json: { errors: ['Form was formed incorrectly'] }, status: 422
      return
    end

    form = Form.find_by(site_id: site.id, name: form_scope)
    if form.blank?
      render json: { errors: ['Form not found'] }, status: 422
      return
    end

    form_datum = FormDatum.create(
      user_id: site.user_id,
      form_id: form.id,
      data: params.fetch(form_scope)
    )

    if form_datum.blank?
      render json: { errors: ['Server error'] }, status: 422
      return
    end

    WebhookTriggerWorker.perform_async(
      'form_submission', site.id, 0, form_datum_id: form_datum.id
    )

    if form.notifications
      NotificationMailer.delay.form_was_submitted(form_datum.id)
    end

    if form.auto_response
      email = find_email(form_datum.data)
      NotificationMailer.delay.auto_response(email, form.id) if email.present?
    end

    if form.redirect_to_url
      render json: { action: 'redirect', url: form.redirect_url }
    else
      message = form.ajax_message.present? ? form.ajax_message : 'Thank you!'
      render json: { action: 'message', text: message }
    end
  end

  def index
    render json: current_user.form_data
  end

  def show
    render json: current_user.form_data.find(params[:id])
  end

  def destroy
    if current_user.form_data.find(params[:id]).destroy
      head :ok
    else
      head status: 422
    end
  end

  def cors
    head :ok
  end

  private

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def find_email(hash)
    hash.each do |k, val|
      return val if val =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    end
    nil
  end
end
