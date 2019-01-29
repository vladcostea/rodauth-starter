require "roda"
require 'sequel/core'
require 'logger'

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::DEBUG


SESSION_SECRET = ENV.fetch('SESSION_SECRET')
SESSION_KEY = ENV.fetch('SESSION_KEY')

DB_SCHEMA = ENV.fetch('DATABASE_AUTH_SCHEMA')
DB_URL = ENV.fetch('DATABASE_ACCOUNTS_URL')

schemas = [DB_SCHEMA, "#{DB_SCHEMA}_password"]
DB = Sequel.connect(DB_URL, search_path: schemas)
DB.extension(:date_arithmetic)
DB.freeze

class App < Roda
  use(
    Rack::Session::Cookie,
    secret: SESSION_SECRET,
    key: SESSION_KEY
  )
  plugin :common_logger, LOGGER
  plugin :middleware

  plugin :rodauth, json: :only do
    db(DB)

    enable(
      :login,
      :logout,
      :create_account,
      :jwt
    )

    jwt_secret(ENV.fetch('JWT_SECRET'))
    function_name { |name| "#{DB_SCHEMA}_password.#{name}" }
    password_hash_table(Sequel["#{DB_SCHEMA}_password".to_sym][:account_password_hashes])
  end

  route do |r|
    r.rodauth
    rodauth.require_authentication
    env['rodauth'] = rodauth

    r.root do
      r.redirect '/hello'
    end

    r.get 'hello' do
      { id: request.env['rodauth'].session_value }
    end
  end
end

run App.freeze.app
