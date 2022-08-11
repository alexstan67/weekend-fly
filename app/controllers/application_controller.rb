class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  
  protected

  def configure_permitted_parameters
    attributes = [:first_name, :last_name, :homebase, :distance_unit]
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :homebase])
    devise_parameter_sanitizer.permit(:account_update, keys: attributes)
  end
end
