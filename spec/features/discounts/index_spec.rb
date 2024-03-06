require 'rails_helper'

RSpec.describe "Discounts#index", type: :feature do
  before(:each) do
    @merch_1 = create(:merchant, name: "Amazon") 

    @discount_1 = @merch_1.discounts.create!(percent_discount: 20, quantity_threshold: 10)
    @discount_2 = @merch_1.discounts.create!(percent_discount: 10, quantity_threshold: 5)

    @cust_1 = create(:customer)
    @cust_2 = create(:customer)
    @cust_3 = create(:customer)
    @cust_4 = create(:customer)
    @cust_5 = create(:customer)
    @cust_6 = create(:customer)
    
    @invoice_1 = create(:invoice, customer_id: @cust_1.id)
    @invoice_2 = create(:invoice, customer_id: @cust_2.id)
    @invoice_3 = create(:invoice, customer_id: @cust_3.id)
    @invoice_4 = create(:invoice, customer_id: @cust_4.id)
    @invoice_5 = create(:invoice, customer_id: @cust_6.id, created_at: "Thu, 22 Feb 2024 22:05:45.453230000 UTC +00:00")
    @invoice_6 = create(:invoice, customer_id: @cust_5.id, created_at: "Wed, 21 Feb 2024 22:05:45.453230000 UTC +00:00")
    
    @trans_1 = create(:transaction, invoice_id: @invoice_1.id)
    @trans_2 = create(:transaction, invoice_id: @invoice_2.id)
    @trans_3 = create(:transaction, invoice_id: @invoice_3.id)
    @trans_4 = create(:transaction, invoice_id: @invoice_4.id)
    @trans_5 = create(:transaction, invoice_id: @invoice_5.id)
    @trans_6 = create(:transaction, invoice_id: @invoice_6.id)

    @item_1 = create(:item, unit_price: 1, merchant_id: @merch_1.id)
    @item_3 = create(:item, unit_price: 1, merchant_id: @merch_1.id, status: 1)

    create(:invoice_item, item_id: @item_1.id, invoice_id: @invoice_1.id, unit_price: 1, quantity: 100, status: 2)
    create(:invoice_item, item_id: @item_1.id, invoice_id: @invoice_2.id, unit_price: 1, quantity: 80, status: 2)
    create(:invoice_item, item_id: @item_1.id, invoice_id: @invoice_3.id, unit_price: 1, quantity: 60, status: 2)
    create(:invoice_item, item_id: @item_1.id, invoice_id: @invoice_4.id, unit_price: 1, quantity: 50, status: 2)
    create(:invoice_item, item_id: @item_3.id, invoice_id: @invoice_5.id, unit_price: 20, quantity: 40)
    create(:invoice_item, item_id: @item_1.id, invoice_id: @invoice_6.id, unit_price: 1, quantity: 5)
  end

    # 1: Merchant Bulk Discounts Index
  it "all discounts listed with their link to show page" do
    # As a merchant
    # When I visit my merchant dashboard
    visit dashboard_merchant_path(@merch_1)
    # Then I see a link to view all my discounts
    # When I click this link
    click_link "All Discounts"
    # Then I am taken to my bulk discounts index page
    expect(current_path).to eq(merchant_discounts_path(@merch_1))
    # Where I see all of my bulk discounts including their
    # percentage discount and quantity thresholds
    # And each bulk discount listed includes a link to its show page
    within '.all-discounts' do
      within "#discount-#{@discount_1.id}" do
        expect(page).to have_link("#{@discount_1.id}")
        expect(page).to have_content(@discount_1.percent_discount)
        expect(page).to have_content(@discount_1.quantity_threshold)
      end
      within "#discount-#{@discount_2.id}" do
        expect(page).to have_link("#{@discount_2.id}")
        expect(page).to have_content(@discount_2.percent_discount)
        expect(page).to have_content(@discount_2.quantity_threshold)
      end
    end
  end

    # 2: Merchant Bulk Discount Create
  it "new form and have the discount listed" do
    # As a merchant
    # When I visit my bulk discounts index
    visit merchant_discounts_path(@merch_1)
    # Then I see a link to create a new discount
    click_link "Create a New Discount"
    # When I click this link
    # Then I am taken to a new page where I see a form to add a new bulk discount
    expect(current_path).to eq(new_merchant_discount_path(@merch_1))
    # When I fill in the form with valid data
    fill_in "percent_discount", with: 40
    fill_in "quantity_threshold", with: 80
    click_button "Submit"
    # Then I am redirected back to the bulk discount index
    expect(current_path).to eq(merchant_discounts_path(@merch_1))
    # And I see my new bulk discount listed
    expect(page).to have_content("40")
    expect(page).to have_content("80")
  end

  # 3: Merchant Bulk Discount Delete
  it "can delete a discount" do
    # As a merchant
    # When I visit my bulk discounts index
    visit merchant_discounts_path(@merch_1)
    # Then next to each bulk discount I see a button to delete it
    # When I click this button
    within "#discount-#{@discount_1.id}" do
      expect(page).to have_content("#{@discount_1.id}")
      expect(page).to have_button("Delete")
    click_button "Delete"
    end 
    expect(page).to_not have_content("#{@discount_1.id}")
  # Then I am redirected back to the bulk discounts index page
  # And I no longer see the discount listed
    expect(current_path).to eq(merchant_discounts_path(@merch_1))
  
    within "#discount-#{@discount_2.id}" do
      expect(page).to have_content("#{@discount_2.id}")
      expect(page).to have_button("Delete")
      click_button "Delete"
    end 
    expect(page).to_not have_content("#{@discount_2.id}")
    expect(current_path).to eq(merchant_discounts_path(@merch_1))
  end

  # 4: Merchant Bulk Discount Show
  it "discount show page" do
    # As a merchant
    # When I visit my bulk discount show page
    visit merchant_discount_path(@merch_1, @discount_1)
   # Then I see the bulk discount's quantity threshold and percentage discount
    expect(page).to have_content(@discount_1.percent_discount)
    expect(page).to have_content(@discount_1.quantity_threshold)
  end

  # 6: Merchant Invoice Show Page: Total Revenue and Discounted Revenue
  it "displays the total revenue and discounted revenue" do
    # As a merchant
    # When I visit my merchant invoice show page
    visit merchant_invoice_path(@merch_1, @invoice_5)
    # Then I see the total revenue for my merchant from this invoice (not including discounts)
    # And I see the total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation
    within "#item-#{@item_3.id}" do 
      expect(page).to have_content("Total Revenue: 800")
      expect(page).to have_content("Total Discount Revenue: 581.5")
    end
  end

  # 7: Merchant Invoice Show Page: Link to applied discounts
  it "link to applied discounts" do
    # As a merchant
    # When I visit my merchant invoice show page
    visit merchant_invoice_path(@merch_1, @invoice_1)
    # Next to each invoice item I see a link to the show page for the bulk discount that was applied (if any)
    within "#item-#{@item_1.id}" do 
      expect(page).to have_link("Applied Discount")
      click_link("Applied Discount")
      expect(current_path).to eq("/merchants/#{@merch_1.id}/discounts/#{@discount_1.id}")
    end
  end

end