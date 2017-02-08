class InvoicesController < ApplicationController

  def index
    invoices = current_user.invoices.as_json
    invoices = invoices['data']
    render :json => {:invoices => invoices}
  end

end
