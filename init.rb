require 'redmine'

Redmine::Plugin.register :redmine_gtt_smash do
  name 'Redmine GTT SMASH Plugin'
  author 'Georepublic'
  description 'Adds SMASH integration capabilities for GTT projects'
  version '0.0.1'
  url 'https://github.com/gtt-project/redmine_gtt_smash'
  author_url 'https://github.com/gtt-project'

  requires_redmine :version_or_higher => '4.0.0'

  # settings default: {
  # }, partial: 'settings/gtt_smash_settings'

  project_module :gtt_smash do
    permission :view_gtt_smash, {
      smash_tags: %i( project_tags global_tags )
    }, require: :member, read: true
  end

end
