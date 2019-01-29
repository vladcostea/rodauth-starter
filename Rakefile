require 'logger'
require 'sequel'
require 'bcrypt'

schemas = [
  ENV.fetch('DATABASE_AUTH_SCHEMA'), 
  "#{ENV.fetch('DATABASE_AUTH_SCHEMA')}_password"
]
db = Sequel.connect(ENV.fetch('DATABASE_ACCOUNTS_URL'), search_path: schemas)

namespace :db do
  desc 'Setup db'
  task :create do
    if env_production?
      puts '* Cannot create db in production!'
      return
    end

    system "createdb -U postgres #{ENV.fetch('DATABASE_NAME')}"
  end

  task :setup do
    dbname = ENV.fetch('DATABASE_NAME')
    schema = ENV.fetch('DATABASE_AUTH_SCHEMA')
    user = ENV.fetch('DATABASE_USER')
    accounts_user = ENV.fetch('DATABASE_ACCOUNTS_USER')
    accounts_password = ENV.fetch('DATABASE_ACCOUNTS_PASSWORD')
    hashes_user = ENV.fetch('DATABASE_HASHES_USER')
    hashes_password = ENV.fetch('DATABASE_HASHES_PASSWORD')

    psql("CREATE USER #{accounts_user} WITH PASSWORD '#{accounts_password}' LOGIN")
    psql("CREATE USER #{hashes_user} WITH PASSWORD '#{hashes_password}' LOGIN")
    psql("GRANT #{accounts_user} TO #{user}")
    psql("GRANT #{hashes_user} TO #{user}")
    psql("CREATE SCHEMA #{schema} AUTHORIZATION #{accounts_user}")
    psql("CREATE SCHEMA #{schema}_password AUTHORIZATION #{hashes_user}")
    psql("GRANT USAGE ON SCHEMA #{schema} TO #{hashes_user}")
    psql("GRANT USAGE ON SCHEMA #{schema}_password TO #{accounts_user}")
    psql("CREATE EXTENSION citext SCHEMA #{schema}")
    psql("ALTER DATABASE #{dbname} OWNER TO #{accounts_user}")
  end

  def migration_version(key)
    ENV[key] ? ENV[key].to_i : nil
  end

  desc 'Run migrations'
  task :migrate do
    require 'sequel/core'
    Sequel.extension :migration
    logger = Logger.new($stderr)
    schema = ENV.fetch('DATABASE_AUTH_SCHEMA')
    version = migration_version('version')
    db = Sequel.connect(ENV.fetch('DATABASE_ACCOUNTS_URL'), logger: logger, search_path: schema)
    if version
      Sequel::Migrator.run(db, 'migrations/auth', target: version)
    else
      Sequel::Migrator.run(db, 'migrations/auth')
    end

    # Migrate ph user tables
    db = Sequel.connect(ENV.fetch('DATABASE_HASHES_URL'), logger: logger, search_path: "#{schema}_password")
    if version
      Sequel::Migrator.run(db, 'migrations/auth_password', table: 'schema_info_password', target: version)
    else
      Sequel::Migrator.run(db, 'migrations/auth_password', table: 'schema_info_password')
    end
  end
end

namespace :auth do
  desc 'Register a new user'
  task :register do
    ARGV.each { |a| task a.to_sym do ; end }
    username = ARGV[1]
    password = ARGV[2]
    hash = BCrypt::Password.create(password, cost: BCrypt::Engine::MIN_COST)
    id = db[:accounts].insert(email: username, status_id: 2)
    db[:account_password_hashes].insert(id: id, password_hash: hash)
    puts "* registered #{username} with id #{id}"
  end
end

def env_production?
  ENV.fetch('RACK_ENV') == 'production'
end

def psql(command)
  system "psql \"#{ENV.fetch('DATABASE_URL')}\" -c \"#{command}\""
end
