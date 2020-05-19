Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :campaigns do
    resources :players, only: [ :new, :create, :show ]

    resources :fights, only: [ :index, :show ]

    get 'log/show', to: 'log#show'
    get 'map/show', to: 'map#show'

    get :controlled_points

    get :initiative_edit
    # post :initiative_save

    get :resolve_movements
    get :show_movements

    get :show_victory_status

    get :input_combats_edit
  end

  get 'players/:campaign_id/choose_faction_new', to: 'players#choose_faction_new', as: 'players_choose_faction_new'

  get 'fights/:movement_result_id/report', to: 'fights#report_edit', as: :fight_report
  post 'fights/:movement_result_id/report', to: 'fights#report_save'

  resources :units, only: [ :edit, :destroy ]

  resources :players, only: [] do
    resources :gangs, only: [ :index, :new, :create ] do
      post :regular_gang
    end

    get :schedule_movements_edit
    post :schedule_movements_save

    get :initiative_bet_edit
    post :initiative_bet_save

    patch :choose_faction_save
  end

  resources :gangs, only: [ :destroy, :edit, :update ] do
    resources :units, only: [ :new, :create, :update, :index ]
  end

  patch 'units/:unit_id/remains', to: 'units#remains'

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
