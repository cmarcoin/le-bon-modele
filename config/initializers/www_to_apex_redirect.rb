# Referenced here rather than in production.rb so Zeitwerk can load the class
# before assets:precompile (environment config runs too early for autoload).
Rails.application.config.middleware.insert_before 0, WwwToApexRedirect
