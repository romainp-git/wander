require 'sidekiq/web'


Rails.application.routes.draw do
  root "pages#home"
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users

  resources :trips, only: %i[show index new edit] do
    resources :trip_activities, only: %i[create index show new edit]
  end
  resources :activities, only: %i[show index update destroy new create]
  resources :destinations, only: %i[index new create show]

  resources :suggestions, only: %i[show]
  resources :searches, only: [:new, :create, :show]

  resources :trip_activities, only: [:update, :index, :destroy]

  get "/test", to: "pages#test"
  get "up" => "rails/health#show", as: :rails_health_check
end
