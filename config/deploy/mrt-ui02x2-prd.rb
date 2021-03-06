# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

set :rails_env, 'production'

puts 'Production branch'
set :branch, 'prod'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/dpr2/apps/ui'

# server 'linux-mjr.ad.ucop.edu', user: 'mreyes', roles: %w{web app}
# server 'uc3-mrt-wrk1-dev.cdlib.org', user: 'dpr2', roles: %w{web app}
server 'uc3-mrtui02x2-prd.cdlib.org', user: 'dpr2', roles: %w[web app]

set :puma_pid, "#{deploy_to}/shared/pid/puma.pid"
set :puma_log, "#{deploy_to}/shared/log/puma.log"
set :puma_port, '26181'

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
