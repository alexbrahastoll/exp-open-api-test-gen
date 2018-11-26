Rails.application.routes.draw do
  get 'cities/:name', to: 'cities#show'
end
