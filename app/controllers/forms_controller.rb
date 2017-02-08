class FormsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_form, only: [:show, :update, :destroy]

  def index
    render json: current_user.forms.active.try(:where, site_id: params[:site_id])
  end

  def show
    render json: @form
  end

  def update
    @form.assign_attributes(form_params)
    if @form.save
      render json: @form
    else
      render json: @form.errors.full_messages, status: 422
    end
  end

  def destroy
    if @form.update(active: false)
      head :ok
    else
      render json: @form.errors.full_messages
    end
  end

  def form_data
    render json: current_user.forms.find(params[:form_id])
  end

  def csv_data
    form = current_user.forms.find(params[:form_id])
    form_data = form.form_data.order('created_at DESC')

    input_names = form_data.first.data.keys.map do |key|
      key.humanize.split.map(&:capitalize).join(' ')
    end if form_data.size > 0

    num = 0
    csv_string = CSV.generate do |csv|
      csv << [' ', 'Form:', form.human_name, 'total:', "#{form_data.size} entries"]
      csv << ['#', 'Submitted At'] + (input_names || [])
      form_data.each do |fd|
        csv << [num += 1, fd.created_at.strftime('%-d %B %Y %I:%M %p')] + fd.data.values
      end
    end

    send_data csv_string, type: 'text/csv', disposition: "inline; filename=#{form.name}.csv", filename: "#{form.name}.csv"
  end

  private

  def set_form
    @form = current_user.forms.find(params[:id])
  end

  def form_params
    params.require(:form).permit(:human_name, :notifications, :auto_response,
                                  :email_address, :email_subject, :email_body,
                                  :ajax_form, :ajax_message, :redirect_to_url,
                                  :redirect_url, :active
                                )
  end
end