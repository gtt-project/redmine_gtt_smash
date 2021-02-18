# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope 'projects/:project_id' do
  resources :smash_tags, only: %i(index), as: :project_smash_tags
end
