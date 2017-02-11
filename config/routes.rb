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
  get 'sub_err'=> 'static_pages#sub_err'

  # Home path
  resources :homes, only: [:index, :update]

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
    resources :register, only: [:edit]
    resources :towers, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
        get 'reset_password/:id' => 'towers#reset_password', as: "reset_password"
      }
    end
  end

  # Home path
  resources :homes

  # Manager permission
  constraints SubdomainConstraint do
    devise_for :accounts

    resources :first_times, only: [:index] do
      collection {
        patch :update_setting
        get :export_building
        get :export_ground
        get :export_citizen
        get :export_owner
        post :import_building
        post :import_ground
        post :import_citizen
      }
    end

    # For dashboard
    # Report by pdf
    get 'report/payment/:id' => 'report#payment'
    get 'report/done_pay/:id' => 'report#done_pay', as: "done_pay"
    get 'report/done_pay_service/:id' => 'report#done_pay_service', as: "done_pay_service"
    get 'report/done_pay_water/:id' => 'report#done_pay_water', as: "done_pay_water"
    get 'report/done_pay_vehicle/:id' => 'report#done_pay_vehicle', as: "done_pay_vehicle"
    get 'report/liabilities_building_summary' => 'report#liabilities_building_summary', as: 'liabilities_building_summary'
    get 'report/liabilities_ground_summary' => 'report#liabilities_ground_summary', as: 'liabilities_ground_summary'
    get 'report/report_list_citizen' => 'report#report_list_citizen', as: 'report_list_citizen'
    get 'report/report_list_ground' => 'report#report_list_ground', as: 'report_list_ground'
    get 'report/report_list_vehicle_card' => 'report#report_list_vehicle_card', as: 'report_list_vehicle_card'
    get 'report/report_list_facility' => 'report#report_list_facility', as: 'report_list_facility'

    # Set dashboard
    resources :dashboard, only: [:index] do
      collection {
        post :map_ground
        post :create_chart
        post :show_ground
      }
    end

    # Set payment path
    resources :payment, only: [:index] do
      collection {
        post :choose_pay
        post :pay
        post :input_water
        get :export_water
        post :import_water
        get :close_finances
      }
    end

    # Set building path
    resources :setbuilding, only: [:index, :create] do
      collection {
        post :createground
        post :buildingchoice
        post :createcitizen
        get  :export
        post :import
        post :liabilities
      }
    end

    # setmaintain path
    resources :setmaintain, only: [:index, :create] do
      collection {
        post :import
        get  :export
      }
    end

    # setfacility path
    resources :setfacility do
      collection {
        post :import
        get  :export
      }
    end

    # Set ground path
    resources :setground, only: [:index, :create] do
      collection {
        get  :export
        post :import
        get  :export_owner
        post :import_owner
        post :ground_service
        post :payout
        post :ground_owner
        post :liabilities
        get :show_images
        patch :upload_images
        post :create_owner
        post :leave_ground
      }
    end

    # Set citizen path
    resources :setcitizen, only: [:index, :create] do
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

    # Set card path
    resources :setcard, only: [:index] do
      collection {
        get :export_vehicle_card
        post :import_vehicle_card
        post :create_vehicle_card
        post :open_vehicle_card
        post :close_vehicle_card
        get "open_service/:id" => "setcard#open_service", as: "open_service"
        get "close_service/:id" => "setcard#close_service", as: "close_service"
        post :payout
      }
    end

    # Set post path
    resources :posts, only: [:index, :create, :update, :destroy] do
      collection {
        post :send_mail
      }
    end

    # Set setting
    resources :setting, only: [:index, :update] do
      collection {
        patch :report
        patch :upload_picture
        post :create_account
        post :update_account
        get :deactive_account
      }
    end

    # For management
    # Building path
    resources :buildings, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
      }
    end

    # Grounds path
    resources :grounds, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
        get :autocomplete
      }
    end

    # Citizen path
    resources :citizens, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
        get :autocomplete
      }
    end

    # Citizen Cards path
    resources :citizen_cards, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
      }
    end

    # Facilities path
    resources :facilities, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
        get :autocomplete
      }
    end

    # Maintains path
    resources :maintains, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
        get :autocomplete
      }
    end

    # Vehicle Cards path
    resources :vehicle_cards, except: [:new, :show, :edit] do
      collection {
        get :export
        post :import
        get :autocomplete
      }
    end

    # Vehicle Finances path
    resources :vehicle_finances, except: [:new, :show, :edit] do
      collection { post :pay }
    end

    # Services path
    resources :services, except: [:new, :show, :edit] do
      collection { post :pay }
    end

    # Water path
    resources :waters, except: [:new, :show, :edit] do
      collection { post :pay }
    end

    # Histories path
    resources :histories, only: [:index]

    # Ground Histories path
    resources :ground_histories, only: [:index]
  end

  match '*path' => redirect('/'), via: :get unless Rails.env.development?
end
