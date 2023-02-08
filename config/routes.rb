Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  get '/current_user', to: 'users#show'
  resources :courses, only: %i[index show create update destroy] do
    resources :instructors, only: %i[destroy]
    resources :lessons, only: %i[create update]
    resources :enrollments, only: %i[index create destroy]
  end
  resources :instruction_invitations, only: %i[index update destroy]
  resources :lessons, only: %i[show destroy]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
