Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#health'
  get '/login', to: 'auth#login'

  resources :posts, only: [:index, :show, :create, :update]
  resources :users, only: [:index, :show]
end
