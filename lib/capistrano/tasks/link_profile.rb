namespace :deploy do

  desc 'Link the appropriate images directory from config/profiles/ to public/'
  task :link_profile do
    on roles(:app) do
      execute :ln, "-nfs #{release_path}/config/profiles/#{fetch(:profile)}/images #{release_path}/public/images"
    end
  end
end
