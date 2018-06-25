require 'socket'

rails_env = ENV['RAILS_ENV'] || 'production'

# 5 workers and 1 master
worker_processes 5

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

pid File.join(Dir.pwd, 'pid', 'unicorn.pid')

# timeout is long because we upload files
# switch to nginx to fix
timeout 7200

logger Logger.new(File.join(Dir.pwd, 'log', 'unicorn.log'))
