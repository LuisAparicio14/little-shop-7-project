class InvoiceItem < ApplicationRecord
  validates :quantity, presence: true
  validates :unit_price, presence: true
  validates :status, presence: true
  
  belongs_to :item
  belongs_to :invoice
  
  enum status: ["pending", "packaged", "shipped"]

  def unit_price_to_dollars
    unit_price/100.00
  end
end
