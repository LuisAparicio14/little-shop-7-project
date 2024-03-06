class Invoice < ApplicationRecord
  validates :status, presence: true
  
  belongs_to :customer
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :discounts, through: :merchants

  enum status: ["in progress", "cancelled", "completed"]
  
  # class method for checking status of invoice
  def self.invoices_with_unshipped_items
    Invoice.select("invoices.*").joins(:invoice_items).where("invoice_items.status != 2")
  end

  def self.oldest_to_newest
    Invoice.order("invoices.created_at")
  end

  def self.invoices_with_unshipped_items_oldest_to_newest
    Invoice.invoices_with_unshipped_items.oldest_to_newest
  end

  def total_revenue_dollars
    invoice_items.sum("quantity * unit_price")/100.00
  end
  
  def total_revenue
    self.invoice_items.sum("unit_price * quantity")
  end

  def discount_item
    x = InvoiceItem.joins(item: { merchant: :discounts})
      .where("discounts.quantity_threshold <= invoice_items.quantity")
      .select("invoice_items.id, MAX(discounts.percent_discount / 100.0 * invoice_items.unit_price * invoice_items.quantity) AS discount_total")
      .group("invoice_items.id")
    x
  end

  def discount_total
    x = discount_item
    x.sum(&:discount_total)
  end

  def total_discount_revenue
    total_revenue - discount_total
  end

  def eligible_discount(item_id)
    invoice_item = self.invoice_items.find{|item| item.item_id == item_id}
    self.discounts.find{|discount| discount.quantity_threshold <= invoice_item.quantity ? true : false }
  end

  def discount(item_id)
    invoice_item = self.invoice_items.find{|item| item.item_id == item_id}
    discount = self.discounts.find{|discount| discount.quantity_threshold <= invoice_item.quantity}
    discount.id
  end
end
