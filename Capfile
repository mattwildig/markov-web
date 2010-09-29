# deploy-settings.rb should set the server role, and the deploy_to var
# e.g. :
# role :server, "example.org"
# set :deploy_to, "/path/to/deploy/dir"

load 'deploy-settings.rb'

desc "Deploy the app"
task :deploy do
  run "cd #{deploy_to} && git pull"
  run "cd #{deploy_to} && touch tmp/restart.txt"
end