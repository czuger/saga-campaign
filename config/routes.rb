Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :campaigns do
    resources :players, except: [ :edit, :update, :index, :destroy ]

    resources :fights, only: [ :index, :new, :create, :show ]

    get 'log/show', to: 'log#show'
    get 'map/show', to: 'map#show'

    get :controlled_points

    get :initiative_edit
    # post :initiative_save

    get :resolve_movements
    get :show_movements
  end

  get 'players/:campaign_id/choose_faction_new', to: 'players#choose_faction_new', as: 'players_choose_faction_new'

  resources :units, only: [ :edit, :destroy ]

  resources :players, only: [] do
    resources :gangs, only: [ :index, :new, :create ]

    get :schedule_movements_edit
    post :schedule_movements_save

    get :initiative_bet_edit
    post :initiative_bet_save

    patch :choose_faction_save
  end

  resources :gangs, only: [ :destroy, :edit, :update ] do
    resources :units, only: [ :new, :create, :update, :index ]
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
