Rails.application.routes.draw do
  root to: "trips#index"
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  resources :trips, only:[:show, :index, :new, :edit] do
    resources :trip_activities, only:[:index, :show, :new, :edit]
  end
  resources :activities, only:[:show, :index, :edit, :destroy ]
  resources :destinations, only:[:index, :new, :create, :show]

 # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
end
