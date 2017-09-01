Rails.application.routes.draw do
  resources :signups
  resources :suggestions
  resources :sites do
    resources :calendars
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'sites#index'

  # Static Pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'

  # User Handling
  resources :users
  get '/signup', to: 'users#new', as: :register
  post '/signup',  to: 'users#create'
  
  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/mon', to: 'site_hits#index'

end
