class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  # disable the bookmarking feature
  def render_bookmarks_control?
    false
  end

  # disable user features
  def has_user_authentication_provider?
    false
  end
end
