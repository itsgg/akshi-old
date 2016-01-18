Akshi::Application.routes.draw do

  resources :sites

  resources :users do
    collection do
      get 'forgot_password'
      post 'send_reset'
    end
    member do
      get 'reset_password'
      put 'update_password'
      get 'courses'
    end

    resources :courses do
      member do
        post :enroll
        post :enroll_by_voucher
        get :pay_online
        get :payment_complete
        get :enter_voucher
        post :dropout
      end
    end
  end

  resources :packages do
    member do
      post :enroll
      post :dropout
      get :pay_online
      get :payment_complete
    end
  end

  resources :sessions

  resources :courses do
    member do
      get :users
      put :update_status
    end

    resources :lessons do
      collection do
        put :sort
      end

      member do
        delete :delete_attachment
        get :conversion_status
        get :preview
        get :download
      end
    end

    resources :topics

    resources :chats

    resource :live

    resources :schedules

    resources :vouchers do
      collection do
        post :generate
      end
    end

    resources :announcements

    resources :ratings

    resources :subjects do
      collection do
        put :sort
      end
    end

    resources :quizzes do
      member do
        post :complete
        get :results
      end
    end
  end

  resources :quizzes do
    resources :questions
    resources :responses
  end

  resources :questions do
    resources :answers
  end

  resources :services do
    collection do
      post :image_to_datauri
    end
  end

  resources :posts do
    resources :comments do
      put :update_status
    end
  end

  namespace :admin do
    resources :courses

    resources :comments

    resources :categories do
      collection do
        put :sort
      end
    end

    resources :collections do
      member do
        put :add_course
        put :remove_course
      end
    end

    resources :users do
      member do
        put :shadow
        get :courses
        post :courses
        put :enroll
      end
    end
  end

  match 'about' => 'pages#about'
  match 'terms_and_conditions' => 'pages#terms_and_conditions'
  match 'privacy_policy' => 'pages#privacy_policy'
  match 'register' => 'users#new'
  match 'login' => 'sessions#new'
  root :to => 'courses#index'

  # Protected downloads
  match '/lessons/uploads/:id/:file' => 'lessons#download'
end
