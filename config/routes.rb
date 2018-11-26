Rails.application.routes.draw do
  resources :notification_requests
  post '/notification_requests/:id/send', to: 'notification_requests#send_notification', as: 'send_notification_request'
  post '/notification_requests/:id/resend', to: 'notification_requests#resend_notification', as: 'resend_notification_request'
  resources :notification_registrations
  resources :resources
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
  resources :users do
    resources :work_logs
  end

  get '/signup', to: 'users#new', as: :register
  post '/signup',  to: 'users#create'
  
  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # These methods are for aggregating data into a single view, intended for driving a single UI screen on the app
end
