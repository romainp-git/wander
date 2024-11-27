Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
  resources :trips, only: %i[show index new edit] do
    resources :trip_activities, only: %i[index show new edit]
  end
  resources :activities, only: %i[show index edit destroy]
  resources :destinations, only: %i[index new create show]

  get 'form', to: 'pages#form'

  resource :trips

  # Defines the root path route ("/")
  # root "posts#index"
end