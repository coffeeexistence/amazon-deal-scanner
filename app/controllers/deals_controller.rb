class DealsController < ApplicationController
  def ebay
    @deals = EbayDeal.includes(:amazon_product).sorted_by_margin.reverse
  end
  
  def book_depot
    @books = WholesaleBook.viable_competitor_price
    
    @books = @books.sort_by do |book|
      price = book.amazon_product.competitor_price
      book.break_even_point / price
    end
  end
  
  def scrape_fba_competition
  end
  
  def asins_to_scrape
    products = WholesaleBook.viable_list_price.find_all do |book|
      book.amazon_product.competitor_price.nil?
    end
    
    formatted_product_data = products.first(50).last(45).map do |book|
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
  
  def stats
    stats = []
    @all = WholesaleBook.all.count
    has_amazon_product = WholesaleBook.includes(:amazon_product).has_amazon_product
    @with_product = has_amazon_product.count
    with_rank_under_100k = has_amazon_product.find_all do |book| 
      book.amazon_product.sales_rank < 100000 if book.amazon_product.sales_rank
    end
    @with_rank_under_100k = with_rank_under_100k.count
    @with_product_details_loaded = has_amazon_product.find_all{|book| book.amazon_product.status == 'ready' }.count
    @with_wholesale_details_loaded = WholesaleBook.details_loaded.count
    with_competitor_price_loaded = has_amazon_product.find_all{|book| book.has_competitor_price? }
    @with_viable_list_price = WholesaleBook.viable_list_price.count
    @with_competitor_price_loaded = with_competitor_price_loaded.count
    
    stats << ["Total", @all]
    stats << ["With product", @with_product]
    stats << ["With rank under 100k", @with_rank_under_100k]
    stats << ["With product details loaded", @with_product_details_loaded]
    stats << ["With wholesale details loaded", @with_wholesale_details_loaded]
    stats << ["With viable list price", @with_viable_list_price]
    stats << ["With competitor price loaded", @with_competitor_price_loaded]
    stats << ["With viable competitor price", WholesaleBook.viable_competitor_price.count]
    
    @stats = stats
  end
  
  private
  
  def amazon_product_params
    params.require(:amazon_product).permit(:competitor_price)
  end
  
end
