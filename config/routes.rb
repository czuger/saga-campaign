Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :campaigns do
    resources :players, except: [ :edit, :update, :index, :destroy ]
    resources :gangs, only: [ :new, :create ]
    get 'log/show', to: 'log#show'
  end

  resources :gangs, only: [ :destroy ] do
    resources :units, only: [ :new, :create, :index ]
    post 'change_location', to: 'gangs#change_location'
  end

  resources :units, only: [ :edit, :update, :destroy ]

  get 'users/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/signout', to: 'sessions#destroy'

  root 'sessions#show' # shortcut for the above

end
