require 'bundler'
Bundler.require

require_rel 'syslib'
Globals.setup

HTTParty::Basement.default_options.update(verify: false) if $env == 'development'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :patch, :options]
  end
end

RolloutService::Config::configure($redis)

RolloutService::Config::set_authentication(->(params){
  response = HTTParty.post('https://www.googleapis.com/oauth2/v3/tokeninfo',
                           body: {id_token: params[:id_token]})
  return nil if response.code != 200

  response_body = JSON.parse(response.body)
  return nil if response_body['hd'] != 'fiverr.com'

  RolloutService::Models::User.new(response_body['name'], response_body['email'])
})

map '/api/v1' do
  run RolloutService::Service
end
