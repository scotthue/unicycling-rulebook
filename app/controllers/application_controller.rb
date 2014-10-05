class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization :unless => :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :location, :comments]
  end

  # Prevent stored_location_for redirecting to a different tenant
  def after_sign_in_path_for(resource)
    location = stored_location_for(resource)
    if location.starts_with?("/r/#{Apartment::Tenant.current}")
      location
    else
      welcome_index_path
    end
  end

  public
  rescue_from CanCan::AccessDenied do |exception|
    if Apartment::Tenant.current
      redirect_to welcome_index_path, alert: exception.message
    else
      redirect_to root_path, :alert => exception.message
    end
  end

  before_filter :load_config

  def load_config
    @config = self.class.get_current_config
  end

  def self.get_current_config
    Rulebook.find_by(subdomain: Apartment::Tenant.current) || Rulebook.first || Rulebook.new
  end

  def self.default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    config = @config || get_current_config
    options.merge({ rulebook_slug: config.subdomain })
  end

  def current_ablity
    current_user.ability
  end

  # breadcrumb methods
  def add_breadcrumb(title, url = nil)
    @breadcrumbs ||= []
    @breadcrumbs << [title, url]
  end

  def render_breadcrumbs
    return if @breadcrumbs.nil?
    res = ""
    @breadcrumbs.each do |br|
      res += "&gt;" unless res.blank?
      res += "<a href='#{br[1]}'>#{br[0]}</a>"
    end
    res.html_safe
  end
  helper_method :render_breadcrumbs

end
