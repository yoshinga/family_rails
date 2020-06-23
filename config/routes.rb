# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'pages#index'
  resources :books
end
