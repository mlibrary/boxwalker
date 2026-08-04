# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join("node_modules/bootstrap-icons/font")
Rails.application.config.assets.paths << Rails.root.join("node_modules/bootstrap/dist/js")
Rails.application.config.assets.precompile << "bootstrap.bundle.min.js"

blacklight_js_assets = Dir[Rails.root.join("node_modules/blacklight-frontend/app/javascript/blacklight/*.js")]
  .map { |path| "blacklight/#{File.basename(path)}" }

Rails.application.config.assets.precompile.concat(blacklight_js_assets)
