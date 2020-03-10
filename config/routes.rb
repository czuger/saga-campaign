Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :campaigns do
    resources :players, except: [ :edit, :update, :index, :destroy ]
    resources :gangs, only: [ :new, :create, :destroy ] do
      resources :units, only: [ :new, :create, :destroy, :index ]
    end
    get 'log/show', to: 'log#show'
  end

  resources :gangs, only: [] do
    post 'change_location', to: 'gangs#change_location'
  end

  get 'users/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/signout', to: 'sessions#destroy'

  root 'sessions#show' # shortcut for the above

end
