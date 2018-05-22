module Globals
  extend self

  def environment
    $env = ENV['RACK_ENV'] || 'development'
  end

  def redis
    config =  YAML.load(File.read('./config/redis.yml'))[$env]
    $redis = Redis.new(config)
  end

  def setup
    environment
    redis
  end
end


