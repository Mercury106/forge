class InvoiceMailer < ActionMailer::Base
  default from: 'Forge Accounts <accounts@getforge.com>'
  layout 'email'
  
  def receipt(user_id, invoice)
    @user = User.find(user_id)
    @invoice = invoice
    mail :to => @user.email, :subject => "Your Forge Invoice"
  end
  
  def payment_failed(user_id, invoice)
    @user = User.find(user_id)
    @invoice = invoice
    mail :to => @user.email, :subject => "Your Forge Invoice - Payment Failed :("
  end
  
end