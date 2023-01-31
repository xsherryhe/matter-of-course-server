Rails.application.routes.draw do
  devise_for :users
  get '/current_user', to: 'users#show'
  resources :courses, only: %i[index]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
