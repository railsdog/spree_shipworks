Rails.application.routes.draw do
  mount Spree::Core::Engine => "/"
  mount SpreeShipworks::Engine => "/shipworks"
end
