role :server, "wildig.org"
set :application, "markov"
set :user, "rails_apps"

set :deploy_to, "/home/#{user}/sinatra/#{application}"

desc "Deploy the app"
task :deploy do
  run "cd #{deploy_to} && git pull"
  
  run "cd #{deploy_to}/ext && ruby extconf.rb"
  run "cd #{deploy_to} && make"
  
  run "cd #{deploy_to} && touch tmp/restart.txt"
end