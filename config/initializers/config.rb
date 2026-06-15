Rails.application.configure do
  # Name of the constant exposing loaded settings
  config.const_name = "Settings"
  p "Is this working?"

  # Load environment variables from the `ENV` object and override any settings defined in files.
  #
  config.use_env = true

end
