class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  # this method appears to change the layout.
  def determine_layout
    'chorus'
  end

  # this method is what the docs SAY you should change to change the layout
  def layout_name
    'chorus'
  end

end
