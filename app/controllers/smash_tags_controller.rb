class SmashTagsController < ApplicationController

  before_action :find_project_by_project_id
  before_action :authorize

  accept_api_auth :index

  def index
    smash_tags = []
    priorities = []
    default_priority = nil
    IssuePriority.active.each do |priority|
      priorities.append({
        item: priority.name
      })
      if priority.is_default
        default_priority = priority.name
      end
    end
    @project.trackers.sort.each do |tracker|
      section = {
        sectionname: tracker.name,
        sectiondescription: "",
        sectionicon: "image",
        forms: [{
          formname: tracker.name,
          formitems: [
            # Default fields
            {
              key: "project_id",
              value: @project.id.to_s,
              type: "hidden",
              mandatory: "yes"
            },
            {
              key: "tracker_id",
              value: tracker.id.to_s,
              type: "hidden",
              mandatory: "yes"
            },
            {
              key: "subject",
              label: l(:field_subject),
              value: "",
              type: "string",
              mandatory: "yes"
            },
            {
              key: "priority_id",
              label: l(:field_priority),
              values: {
                items: priorities
              },
              value: default_priority,
              type: "stringcombo",
              mandatory: "yes"
            },
            {
              key: "is_private",
              label: l(:field_is_private),
              type: "boolean",
              mandatory: "yes"
            },
            # TODO: Need to check 
            # assigned_to_id, category_id, fixed_version_id, parent_issue_id,
            # start_date, due_date, estimated_hours, done_ratio
            {
              key: "description",
              label: l(:field_description),
              value: "",
              type: "string"
            }
          ]
        }]
      }
      smash_tags.append(section)
    end
    respond_to do |format|
      format.api { render json: smash_tags }
    end
  end
end
