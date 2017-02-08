#encoding: UTF-8

class User < ActiveRecord::Base
  module Billing
    extend ActiveSupport::Concern

    def self.included(base)
      base.class_eval do
        attr_accessor :stripe_card_token
        attr_accessible :coupon, :stripe_card_token, :subscription_active

        # before_save :save_with_stripe_card_token_and_create_stripe_customer
        # after_save :change_plan_on_stripe_if_plan_id_changed, unless: 'Rails.env.test?'
        # before_save :save_coupon_if_added
        # before_save :update_stripe_plan

        before_destroy :destroy_stripe_customer
      end
    end

    def process_billing(plan_id = false)
      if plan_id
        plan_id = 'basic' unless ['basic', 'pro'].include?(plan_id)
        self.plan_id = plan_id
      end
      save_with_stripe_card_token_and_create_stripe_customer
      save_coupon_if_added
    end

    def change_plan!(plan_id)
      if ['basic', 'pro'].include?(plan_id) && stripe_customer
        stripe_customer.update_subscription(plan: plan_id)
        update_column(:plan_id, plan_id)
      elsif plan_id == 'free' && sites.count == 0
        cancel_subscription
      end
    end

    def update_stripe_plan
      if !plan_id_changed?
        plan = self.try(:stripe_customer).try(:subscription).try(:plan).try(:id)
        if plan
          self.plan_id = plan
        end
      end
    end

    def self.currency_symbol
      "$"
    end

    def currency
      "usd"
    end

    def self.currency
      "usd"
    end

    # Invoices
    def invoices
      return {} unless stripe_customer
      stripe_customer.invoices
    end

    def upcoming_invoice
      Stripe::Invoice.upcoming :customer => stripe_customer_token
    end

    def stripe_customer
      if stripe_customer_token
        @customer ||= Stripe::Customer.retrieve(stripe_customer_token) rescue nil
      else
        nil
      end
    end

    # Billing and Invoicing

    # TODO: move this into stripe objects
    def plan_cost
      if plan_id == 'pro'
        return 2000
      else
        return 1000
      end
    end

    def bandwidth_cost_this_month
      billable_bandwidth = bandwidth_this_month - number_of_free_gigabytes.gigabytes
      billable_bandwidth = 0 if billable_bandwidth < 0
      cost = billable_bandwidth / 1.gigabyte * PENCE_PER_GIG
    end

    include ActionView::Helpers::NumberHelper

    # In cents
    def cost_this_month
      bandwidth_cost_this_month + plan_cost
    end

    def unbilled_usage
      self.sites.collect(&:unbilled_usage).sum
    end

    def bill_plan_vat_as_charge
      if charge_vat?
        amount = plan_cost
        amount = amount * 0.2
        # create_invoice_item("VAT at 20%", amount.to_i, nil)
      end
    end

    def bill_unbilled_usage_to_invoice(invoice_id)

      invoice = Stripe::Invoice.retrieve(invoice_id)
      return if invoice.closed

      free_usage = self.number_of_free_gigabytes.gigabytes
      create_invoice_item("#{number_to_human_size free_usage} free bandwidth", 0, invoice_id)

      billable_usage = unbilled_usage - free_usage
      if billable_usage > 0
        amount_in_cents = self.cost_for(billable_usage)
        create_invoice_item("#{number_to_human_size billable_usage} paid bandwidth", amount_in_cents.to_i, invoice_id)
      end

      self.sites.each do |site|
        site.mark_as_billed!
      end
    end


    def bill_date_range_to_invoice(range, invoice_id)

      invoice = Stripe::Invoice.retrieve(invoice_id)
      return if invoice.closed

      # TODO: ensure this free usage accounts for the range in question.
      free_usage = self.number_of_free_gigabytes.gigabytes

      create_invoice_item("#{number_to_human_size free_usage} free bandwidth", 0, invoice_id)

      total_bandwidth_in_period = 0
      sites.each do |site|
        total_bandwidth_in_period += site.bandwidth_range(range)
      end

      billable_usage = total_bandwidth_in_period - free_usage
      amount_in_cents = self.cost_for(billable_usage)

      if amount_in_cents > 0
        create_invoice_item("#{number_to_human_size billable_usage} paid bandwidth", amount_in_cents.to_i, invoice_id)
      else
        # Important! We subtract this later.
        amount_in_cents = 0
      end

      # Charge VAT if they're in the EU.
      # We only have to charge VAT if they give us a VAT number.
      if charge_vat?

        if invoice
          # The rescue here is for the tests, which refer to an invoice's total.
          # The discount is applied before any of this so the total comes back as the full amount.
          # It's remarkably silly.
          vat_amount_in_cents = 0.2 * invoice.subtotal
          if vat_amount_in_cents.to_i > 0
            # create_invoice_item("VAT at 20%", vat_amount_in_cents.to_i, invoice_id)
          end
        end

        # if Rails.env.test?
        #   amount_we_charge_vat_on = plan_cost
        #   # Important - don't subtract this number or we'll get a total that's less than the plan cost.
        #   if amount_in_cents > 0
        #     amount_we_charge_vat_on += amount_in_cents
        #   end
        #   vat_amount_in_cents = 0.2 * amount_we_charge_vat_on
        # end

      end

      # We may not need this now that we're not using last_billed_at.
      # TOOD: possibly remove this.
      sites.each do |site|
        site.mark_as_billed!
      end

    end

    def charge_vat?
      # in_eu?
      false
    end

    def in_eu?
      if country
        country_object = Country.find_country_by_name(country)
        country_object.in_eu?
      else
        false
      end
    end

    def create_invoice_item(description, amount, invoice_id)
      options = {
        :customer => stripe_customer_token,
        :description => description,
        :amount => amount,
        :currency => currency,
        :invoice => invoice_id
      }

      return Stripe::InvoiceItem.create(options)
    end

    # USD_PER_GIG = 1.0
    # GBP_PER_GIG = 0.6
    CENTS_PER_GIG = 20

    def self.cost_for(bytes)
      if bytes > 0
        bytes / 1.gigabyte * CENTS_PER_GIG
      else
        0
      end
    end

    def cost_for(bytes)
      bytes / 1.gigabyte * CENTS_PER_GIG
    end

    def destroy_stripe_customer
      if self.stripe_customer
        self.stripe_customer.delete rescue true
      end
    end

    def change_plan_on_stripe_if_plan_id_changed
      if plan_id_changed?
        if self.plan_id == 'free'
          self.plan_id = 'basic'
        end
        if self.stripe_customer
          self.stripe_customer.update_subscription(:plan => plan_id)
        end
      end
    end

    def save_with_stripe_card_token_and_create_stripe_customer
      if self.stripe_card_token

        if self.plan_id == 'free'
          self.plan_id = 'basic'
        end
        self.plan_id ||= 'basic'

        if !self.stripe_customer_token
          # debugger
          customer = Stripe::Customer.create(email: email, card: stripe_card_token, coupon: coupon)

          self.stripe_customer_token = customer.id

          # invoice vat
          bill_plan_vat_as_charge()

          # customer.card = nil
          customer.plan = plan_id
          customer.save

          self.stripe_customer_token = customer.id
          @customer = customer
        else
          self.stripe_customer.card = self.stripe_card_token
          self.stripe_customer.save
        end

        if customer && customer.respond_to?(:discount) && customer.discount.respond_to?(:coupon)
          self.discount = customer.discount.coupon.percent_off.to_f / 100
        else
          self.discount = 0
        end

        @customer = customer

        self.stripe_card_token = nil
      end
    rescue Stripe::InvalidRequestError => e
      puts e.message
      logger.error "Stripe error while creating customer: #{e.message}"
      errors.add :base, e.message
      # errors.add :base, "There was a problem with your credit card."
      false
    rescue Stripe::CardError => e
      errors.add :base, "There was a problem with your credit card."
      false
    end

    def subscription_active
      !stripe_customer_token.nil?
    end

    def subscription_active=(value)
      if !value
        cancel_subscription
      end
    end

    def cancel_subscription
      begin
        if stripe_customer
          stripe_customer.cancel_subscription
        end
      rescue Stripe::InvalidRequestError => e
        # The stripe customer didn't exist.
      end
      update_columns(plan_id: 'free', stripe_customer_token: nil)
    end

    def save_coupon_if_added
      if coupon_changed? && coupon
        subscription = self.stripe_customer.subscription
        subscription.coupon = self.coupon
        subscription.save()
      end
    rescue => e
      errors.add(:coupon, "was not found!")
      false
    end

  end
end