Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
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
    put '/certifications/:id', to: 'certification_grants#create'
    delete '/certifications/:id', to: 'certification_grants#destroy'
  end
  post '/certifications/', to: 'certifications#create'
  put '/certifications/:id', to: 'certifications#update'
  delete '/certifications/:id', to: 'certifications#destroy'
  get '/certifications/', to: 'certifications#index'

  get '/signup', to: 'users#new', as: :register
  post '/signup',  to: 'users#create'
  
  get '/login',    to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/organizations', to: 'organizations#index'
  get '/organizations/:organization_id/sites', to: 'sites#index'
  post '/organizations', to: 'organizations#create'
  delete '/organizations/:id', to: 'organizations#destroy'

  # These methods are for aggregating data into a single view, intended for driving a single UI screen on the app
end
