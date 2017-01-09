class BookDepotApi

  def self.get_books_from_page(page_url)
    doc = Nokogiri::HTML open(page_url)
    doc.css('.product-details').map do |book|
      url = book.css('dt a')[0]['href']
      isbn_matches = url.match(/R-(\d{13})B/)
      isbn = isbn_matches ? isbn_matches[1] : ""
      { url: url, isbn: isbn, html_src: book.to_html }
    end
  end
  
end