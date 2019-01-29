## Rodauth starter

## Example .env

```
export RACK_ENV=development
export DATABASE_URL="postgres://postgres@localhost:5432/rodauth_dev?sslmode=disable"
export DATABASE_NAME=rodauth_dev
export DATABASE_AUTH_SCHEMA=auth
export DATABASE_USER=postgres
export DATABASE_PASSWORD=postgres
export DATABASE_HOST=localhost
export DATABASE_PORT=5432
export DATABASE_ACCOUNTS_USER=accounts
export DATABASE_ACCOUNTS_PASSWORD=password
export DATABASE_ACCOUNTS_URL=postgres://accounts:password@localhost:5432/rodauth_dev
export DATABASE_HASHES_USER=accounts_password
export DATABASE_HASHES_PASSWORD=password
export DATABASE_HASHES_URL=postgres://accounts_password:password@localhost:5432/rodauth_dev
export SESSION_KEY=_rodauth_starter
export SESSION_SECRET=c5d73bd5474dd4215eb735fd22976e0c2f223169c648485bc37c4bf2dd18
export JWT_SECRET=secret
```

## Setup and migrate

```
bundle exec rake db:create
bundle exec rake db:setup
bundle exec rake db:migrate
```

## Run

```
bundle exec puma -p 4000 config.ru
```

### JWT login

```
curl -XPOST http://localhost:4000/login \
  -H "Content-Type: application/json" \
  -d '{"login": <username>, "password": <password>}'
```

If all goes well, you should receive an `Authorization` header. 

Use that header in all subsequent requests

```
curl http://localhost:4000/hello \
  -H "Authorization: <header>.<payload>.<sig>
```
