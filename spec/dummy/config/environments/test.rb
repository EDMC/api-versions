Dummy::Application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
  config.secret_key_base = "eb6e66d4263b36e93912a0e0c367059d38c3417058890737c1bed0e52961429817430c38be6acab423cf023fe51c05123727f4dd4782cb2a46966d496d8e951c"
  config.secret_token = "35c2d7361ce46603d587097392f7397748e94216a275d34f0449fe3db03c36e19e998950317bd2bfc28f1cfa4d106792ff346949ecb8209911995480d4668530"
end
