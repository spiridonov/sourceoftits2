require 'resque/server'
require 'resque_scheduler'

Web::Application.routes.draw do
  mount Resque::Server.new, :at => "/resque"

  #devise_for :users

  resources :tits, :only => [:create, :delete, :show] do
    collection do
      get 'pending'
      get 'approved'
      get 'rejected'
      get 'published'
    end

    member do
      put 'approve'
      put 'reject'
    end
  end

end
