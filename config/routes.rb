Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  resources :instruments
  resources :quotes do
    resources :instruments
  end
  match '*unmatched', to: 'application#route_not_found', via: :all
end
