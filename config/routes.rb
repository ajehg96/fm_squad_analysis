# frozen_string_literal: true

# config/routes.rb
Rails.application.routes.draw do
  # Creates routes for new, create, and show
  resources :squad_analyses, only: [:new, :create, :show]

  # Make the upload page the root of your application
  root "squad_analyses#new"
end
