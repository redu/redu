ActionController::Base.session = {
  :key         => '_uploadify_rails_session',
  :secret      => 'woot!'
}

ActionController::Dispatcher.middleware.insert_before(
  ActionController::Base.session_store,
  FlashSessionCookieMiddleware, # <-- here is where it goes!
  ActionController::Base.session_options[:key]
)
