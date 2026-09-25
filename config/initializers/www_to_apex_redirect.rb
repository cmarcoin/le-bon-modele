require "www_to_apex_redirect"

Rails.application.config.middleware.insert_before 0, WwwToApexRedirect
