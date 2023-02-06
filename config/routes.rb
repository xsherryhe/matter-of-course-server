Rails.application.routes.draw do
  get 'lessons/create'
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  get '/current_user', to: 'users#show'
  resources :courses, only: %i[index show create update destroy] do
    resources :instructors, only: %i[destroy]
    resources :lessons, only: %i[create update]
  end
  resources :instruction_invitations, only: %i[index update destroy]
  resources :lessons, only: %i[show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
