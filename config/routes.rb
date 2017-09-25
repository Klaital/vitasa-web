Rails.application.routes.draw do
  post '/notificationn_requests/send', to: 'notification_requests#send'
  resources :notification_requests
  resources :notification_registrations
  resources :resources
  resources :signups
  resources :suggestions
  resources :sites do
    resources :calendars
  end
  get '/dashboards/sites', to: 'aggregates#sites_status'
  get '/dashboards/hours', to: 'aggregates#user_hours'

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

  # These methods are for aggregating data into a single view, intended for driving a single UI screen on the app
  get '/schedule', to: 'aggregates#schedule'
end
