Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :campaigns do
    resources :players, except: [ :edit, :update, :index, :destroy ] do
      put :modify_pp
    end

    resources :gangs, only: [ :index, :new, :create, :edit, :update ]

    resources :fights, only: [ :index, :new, :create, :show ]

    get 'log/show', to: 'log#show'
    get 'map/show', to: 'map#show'

    get :controlled_points
  end

  resources :gangs, only: [ :destroy ] do

    resources :units, only: [ :new, :create, :update, :index ]
    post 'change_location', to: 'gangs#change_location'

  end

  resources :units, only: [ :edit, :destroy ]

  resources :players, only: [] do
    patch :modify_pp
  end

  # Used to set icons position on map
  get 'map/create_positions', to: 'map#create_positions'
  post 'map/save_position', to: 'map#save_position'

  get 'map/modify_positions', to: 'map#modify_positions'
  post 'map/save_position', to: 'map#save_position'


  get 'users/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/signout', to: 'sessions#destroy'

  root 'sessions#show' # shortcut for the above

end
