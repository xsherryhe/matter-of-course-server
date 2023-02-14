Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', sessions: 'sessions' }
  get '/current_user', to: 'users#show'
  resources :courses, only: %i[index show create update destroy] do
    resources :instructors, only: %i[destroy]
    resources :lessons, only: %i[create]
    resources :enrollments, only: %i[index create destroy]
    resources :assignment_submissions, only: %i[index]
  end
  resources :instruction_invitations, only: %i[index update destroy]
  resources :messages, only: %i[show create update]
  get '/current_messages/:type', to: 'messages#index'
  resources :lessons, only: %i[show update destroy]
  resources :assignments, only: %i[show destroy] do
    resources :assignment_submissions, only: %i[index create update], path: 'submissions'
  end
  resources :assignment_submissions, only: %i[show destroy]
  get '/assignments/:assignment_id/current_submission', to: 'assignment_submissions#show'
  resources :posts, only: %i[show update destroy]
  get '/:postable_type/:postable_id/posts', to: 'posts#index'
  post '/:postable_type/:postable_id/posts', to: 'posts#create'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
