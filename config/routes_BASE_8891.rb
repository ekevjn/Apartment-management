class MaindomainConstraint
  def self.matches?(request)
    request.subdomain.blank? || request.subdomain == 'wwww'
  end
end

class SubdomainConstraint
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != 'www'
  end
end

Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

  # Permission for all
  root 'homes#index'
  get 'help'=> 'static_pages#help'
  get 'sub_err'=> 'static_pages#sub_err'

  # Report by pdf
  get 'report/payment/:id' => 'report#payment'
  get 'report/done_pay/:id' => 'report#done_pay', as: "done_pay"
  get 'report/done_pay_service/:id' => 'report#done_pay_service', as: "done_pay_service"
  get 'report/done_pay_water/:id' => 'report#done_pay_water', as: "done_pay_water"
  get 'report/done_pay_vehicle/:id' => 'report#done_pay_vehicle', as: "done_pay_vehicle"

  # Admin permission
  constraints MaindomainConstraint do
    get 'register/choose' => 'register#choose'
    get 'register' => 'register#new'
    post 'register' => 'register#create'
    get 'admin/login' => 'admin_sessions#new'
    post 'admin/login' => 'admin_sessions#create'
    delete 'admin/logout' => 'admin_sessions#destroy'
    get 'admin/change_password' => 'admin#change_password'
    patch 'admin/update_password' => 'admin#update_password'
    get 'admin/support' => 'admin#support'
    resources :register, only: [:edit]
    resources :towers do
      collection {
        get :export
        post :import
      }
    end
  end

  # Home path
  resources :homes

  # Ground path
  resources :grounds do
    collection {
      get :export
      post :import
      get :autocomplete
    }
  end

  # Manager permission
  #constraints SubdomainConstraint do
  devise_for :accounts
  #end

  # Building path
  resources :buildings do
    collection {
      get :export
      post :import
    }
  end

  # Citizen path
  resources :citizens do
    collection {
      get :export
      post :import
      get :autocomplete
    }
  end

  # Citizen card path
  resources :citizen_cards do
    collection {
      get :export
      post :import
    }
  end

  # Facilities path
  resources :facilities do
    collection { post :import }
  end

  # Vehicle Card path
  resources :vehicle_cards do
    collection {
      get :export
      post :import
      get :autocomplete
    }
  end

  # Vehicle Finance path
  resources :vehicle_finances do
    collection { post :pay }
  end

  # Services path
  resources :services do
    collection { post :pay }
  end

  # Water path
  resources :waters do
    collection { post :pay }
  end

  # histories path
  resources :histories

  # Set Building path
  resources :setbuilding do
    collection {
      post :createground
      post :buildingchoice
      post :createcitizen
      get  :export_building
      post :import_building
      post :import_ground
      post :import_citizen
      post :liabilities
    }
  end

  # Set ground path
  resources :setground do
    collection {
      get  :export
      post :import
      post :ground_service
      post :ground_owner
      post :liabilities
    }
  end


  # Set citizen path
  resources :setcitizen do
    collection {
      get  :export
      post :import
      get  :export_citizen_card
      post :import_citizen_card
      post :create_citizen_card
      post :citizen_card_close
      get "citizen_card_lost/:id" => "setcitizen#citizen_card_lost", as: "citizen_card_lost"
      get "citizen_card_lock/:id" => "setcitizen#citizen_card_lock", as: "citizen_card_lock"
    }
  end

  # Set payment path
  resources :payment do
    collection {
      post :choose_pay
      post :pay
      post :input_water
      get :export_water
      post :import_water
      get :close_finances
    }
  end

  # Set card path
  resources :setcard do
    collection {
      get :export_vehicle_card
      post :import_vehicle_card
      post :create_vehicle_card
      post :map_ground
    }
  end


  # Set dashboard
  resources :dashboard do
    collection {
      post :map_ground
      post :create_chart
    }
  end

  # Set setting
  resources :setting do
    collection {
      patch :report
      post :create_account
      post :update_account
    }
  end

  # Set post path
  resources :posts do
    collection {
      post :send_mail
    }
  end
end
