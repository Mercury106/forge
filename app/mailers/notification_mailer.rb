class NotificationMailer < ApplicationMailer
  default from: 'Forge Forms <admin@getforge.com>'
  layout 'email'
  
  def form_was_submitted(form_datum_id)
    @form_data = FormDatum.find(form_datum_id)
    @form = @form_data.form
    mail(to: @form.user.email,
         subject: "Your Forge Form \"#{@form.human_name}\" has a new response"
        )
  end

  def auto_response(email, form_id)
    form = Form.find(form_id)
    mail(to: email,
         from: form.email_address,
         subject: form.email_subject) do |format|
      format.text { render text: form.email_body }
    end
  end
end
