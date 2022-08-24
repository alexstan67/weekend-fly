Rails.application.routes.draw do
  resources :trip_inputs, only: [:new, :create, :edit, :update] 
  get 'trip_outputs/index'
  get 'pages/home'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "pages#home"
end
