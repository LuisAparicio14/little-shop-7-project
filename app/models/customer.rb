class Customer < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  has_many :invoices, dependent: :destroy
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  def self.top_five_customers
    Customer
    .select("customers.*, count(transactions.result = 0) as successful_transactions")
    .joins(:transactions)
    .group('customers.id')
    .order('successful_transactions desc')
    .limit(5)
  end

  def successful_transactions_count 
    transactions.count("transactions.result = 0")
  end
end
