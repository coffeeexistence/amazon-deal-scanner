class TaskManager
  @@last_tick = DateTime.now - 1.seconds
  @@iterations = 0
  
  def self.start
    @@last_tick = DateTime.now - 1.seconds
    @@iterations = 0
    loop do
      tick = self.tick
      if tick == 'waiting'
        puts tick
      else
        self.status_update if @@iterations % 10 == 0
        puts tick
      end
      
    end
  end
  
  def self.tick
    output = ""
    if @@last_tick > DateTime.now - 1.seconds
      sleep 0.5
      return "waiting"
    else
      @@last_tick = DateTime.now
    end

    if AmazonProduct.pending.any? # Both almost complete
      output << "\nLoading pending AmazonProducts: "
      output << AmazonProduct.update_pending_product_from_api.to_s
    elsif AmazonProduct.books.ready.search_due.any?
      output << "\nFinding Book deals: "
      output << AmazonProduct.find_book_deals.to_s
    else
      output << "\nRunning product search task: "
      output << ProductSearchTask.run_random_active_job.to_s
    end
    output
  end
  
  def self.status_update
    pending = AmazonProduct.pending.count
    ready = AmazonProduct.ready.count
    deals = EbayDeal.all.count
    highest_margin = EbayDeal.highest_margin
    puts "#\n#\nSTATUS UPDATE:\n#"
    puts "Amazon Products: #{pending}(pending) #{ready}(ready)"
    puts "Ebay Deals: #{deals}"
    puts "Highest Margin found: #{highest_margin}"
    puts "#\n#\n#\n"
  end
  
  def self.all_pages_by_term(term:, page_count:)
    current_page = 0
    
    (page_count).times do |i|
      begin
        page = "http://www.bookdepot.com/Store/Browse/_/N-0/No-#{i*48}/Ntk-Default/Ntt-a?terms="
        WholesaleBook.create_batch_from_book_depot_page(page)
      rescue
        puts "FAILED: #{page}"
      end
    end
  end
  
end