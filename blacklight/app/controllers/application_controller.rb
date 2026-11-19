class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # disable the bookmarking feature
  def render_bookmarks_control?
    false
  end

  # disable user features
  def has_user_authentication_provider?
    false
  end
end
