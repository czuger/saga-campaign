I18n.config.load_path += Dir["#{Rails.root.to_s}/config/locales/**/*.{rb,yml,yaml}"]

I18n.config.available_locales = [ :fr, :en ]
I18n.default_locale = :fr