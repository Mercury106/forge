class AddLastInvoicedToSites < ActiveRecord::Migration
  def change
    add_column :sites, :last_invoiced_at, :datetime
  end
end
