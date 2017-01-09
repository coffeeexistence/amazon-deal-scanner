class DealsController < ApplicationController
  def ebay
    @deals = EbayDeal.includes(:amazon_product).sorted_by_margin.reverse
  end
  
  def book_depot
    @books = WholesaleBook.viable_sorted_by_sales_rank.find_all do |book|
      if book.amazon_product.competitor_price
        book.amazon_product.competitor_price > (book.break_even_point + book.minimum_profit)
      else
        false
      end
    end
    
    @books = @books.sort_by do |book|
      price = book.amazon_product.competitor_price || book.amazon_product.list_price
      book.break_even_point / price
    end
  end
  
  def scrape_fba_competition
  end
  
  def asins_to_scrape
    products = WholesaleBook.viable_sorted_by_sales_rank.find_all do |book|
      book.amazon_product.competitor_price.nil?
    end
    
    formatted_product_data = products.first(20).map do |book|
      { asin: book.amazon_product.asin, id: book.amazon_product.id }
    end
    
    render json: formatted_product_data
  end
  
  def post_fba_competition
    product = AmazonProduct.find_by_id(params[:id])
    product.update_attributes amazon_product_params
    status = product.save
    render json: {success: status}
  end
  
  private
  
  def amazon_product_params
    params.require(:amazon_product).permit(:competitor_price)
  end
  
end
