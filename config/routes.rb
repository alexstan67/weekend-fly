Rails.application.routes.draw do
  get 'trip_inputs/new'
  get 'trip_inputs/create'
  get 'pages/home'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  #get '/trip_input', to: 'trip_input#new'
  #post '/trip_input', to: 'trip_input#create'

  # Defines the root path route ("/")
  root to: "pages#home"
end
