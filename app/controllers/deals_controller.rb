class DealsController < ApplicationController
  def ebay
    @deals = EbayDeal.includes(:amazon_product).sorted_by_margin.reverse
  end
end
