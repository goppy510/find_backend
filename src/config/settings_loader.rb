require 'settingslogic'

# Define a Settings class to load the settings files
class Settings < Settingslogic
  source "#{Rails.root}/config/settings/#{Rails.env}.yml"
  namespace Rails.env
end
