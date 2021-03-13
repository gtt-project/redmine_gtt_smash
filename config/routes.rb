# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope 'smash' do
  get 'tags', to: 'smash_tags#global_tags', as: :smash_tags
end

scope 'projects/:project_id' do
  scope 'smash' do
    get 'tags', to: 'smash_tags#project_tags', as: :project_smash_tags
  end
end
