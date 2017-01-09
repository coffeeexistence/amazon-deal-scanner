Rails.application.routes.draw do
  get 'deals/ebay'
  get 'deals/book_depot'
  get 'deals/scrape_fba_competition'
  get 'deals/asins_to_scrape'
  post 'deals/post_fba_competition/:id', to: 'deals#post_fba_competition'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
