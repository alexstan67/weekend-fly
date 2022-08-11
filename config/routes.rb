Rails.application.routes.draw do
  get 'trip_outputs/index'
  get 'trip_inputs/new'
  get 'trip_inputs/create'
  post 'trip_inputs/create'
  get 'pages/home'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: "pages#home"
end
