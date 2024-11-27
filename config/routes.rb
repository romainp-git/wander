Rails.application.routes.draw do
  root to: "trips#index"
  devise_for :users
  
  resources :trips, only: %i[show index new edit] do
    resources :trip_activities, only: %i[index show new edit]
  end
  resources :activities, only: %i[show index edit destroy]
  resources :destinations, only: %i[index new create show]
    
  get 'form', to: 'pages#form'
  get "up" => "rails/health#show", as: :rails_health_check
end
