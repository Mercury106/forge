class WebHooksController < ApplicationController

  before_filter :save_webhook, :only => [:incoming]
  before_filter :debug_event_information
  before_filter :skip_non_stripe_events
  before_filter :skip_test_messages_in_production

  def incoming
    method = event_type.gsub(".", "_")
    if self.respond_to? method
      self.send method
    end
    render text: 'Your request was successfully received.'
  end

  ## Site deploy

  def redeploy
    user_id = User.find_by(authentication_token: params[:token]).try(:id)
    url = params[:url] || params[:text]
    site = Site.where(user_id: user_id, url: url).first
    return unless user_id && site
    site.redeploy!(params[:cache], params[:delay])
  end
  
  ## Invoices

  # Invoice_created means we have to bill them their extra usage now.
  def invoice_created
    invoice_id    = object['id']
    invoice_start = Time.at(object['period_start'].to_i)
    invoice_end   = Time.at(object['period_end'].to_i)
    range = invoice_start..invoice_end
    user.bill_date_range_to_invoice(range, invoice_id)
  end

  def invoice_payment_succeeded
    InvoiceMailer.receipt(user.id, object).deliver
  end

  def invoice_payment_failed
    InvoiceMailer.payment_failed(user.id, object).deliver
  end


  ## Updating accounts
  
  def account_updated
    # TODO: 
    # user.update_from_stripe()
    # Update relevant user from Stripe
  end

  def customer_deleted
    # Delete a user's subscription.
    raise "That user wasn't found!" unless user

    user.update_attribute :stripe_customer_token, nil
  end

  def customer_subscription_deleted
    if user
      user.update_attribute :stripe_customer_token, nil
    else
      log "Couldn't find a user."
    end
  end

  def customer_subscription_created
    customer = Stripe::Customer.retrieve(object['customer'])
    user = User.find_by_email customer.email

    if user
      user.update_attribute(:stripe_customer_token, object['customer'])
      user.save()

      # user.bill_plan_vat_as_charge
    else
      # TODO: Track me.
      throw "No user found with email #{customer.email}."
    end
  end

private

  def save_webhook
    Webhook.create(data: request.params, stripe_id: request.params['id'], live: request.params['livemode'] == "true")
  end

  def debug_event_information
    puts
    puts
    if event_type && event_type != 'redeploy'
      user = User.find_by_stripe_customer_token(object['customer'])

      log "Webook received: #{event_type}"
      log "Stripe customer: #{object['customer']}"
      log "User: #{user}"
    end
  end

  def skip_test_messages_in_production
    if request.params['livemode'] == "false" && Rails.env.production?
      render :text => "Test webhook. Disregarding."
      return
    end
  end

  def object
    return {} if request.params['data'].blank?
    @object ||= request.params['data']['object']
  end

  def user
    customer = object['customer']
    @user ||= User.find_by_stripe_customer_token customer
  end

  def event_type
    params['type']
  end

  def skip_non_stripe_events
    if !event_type
      render :text => ""
    end
  end

  def log(text)
    message = "[webhooks_controller] #{text}"
    if Rails.env.development?
      puts message
    else
      logger.debug message
    end
  end

end
