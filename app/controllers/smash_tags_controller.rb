class SmashTagsController < ApplicationController

  before_action :find_project_by_project_id
  before_action :authorize

  accept_api_auth :index

  def index
    smash_tags = []
    priorities = []
    default_priority = nil
    # SMASH (Geopaparazzi) form spec: https://www.geopaparazzi.org/geopaparazzi/index.html#_using_form_based_notes
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
      # Attachments
      section[:forms][0][:formitems].append({
        key: "attachments",
        value: "",
        type: "pictures"
      })
      # IssueCustomField mapping
      # Redmine: https://github.com/redmine/redmine/blob/master/lib/redmine/field_format.rb
      IssueCustomField.where(is_for_all: true).sort.each do |icf|
        type = "string"
        values = []
        case icf.field_format
        when "string", "text", "link"
          type = "string"
        when "int"
          type = "integer"
        when "float"
          type = "double"
        when "date"
          type = "date"
        when "bool"
          type = "boolean"
        when "list"
          type = (icf.multiple ? "multistringcombo" : "stringcombo")
          icf.possible_values.each do |v|
            values.append({
              item: v
            })
          end
        when "enumeration"
          type = (icf.multiple ? "multistringcombo" : "stringcombo")
          icf.enumerations.where(active: true).sort.each do |e|
            values.append({
              item: e.name
            })
          end
        when "user", "version", "attachment"
          # Can't map SMASH object
          type = "hidden"
        end
        if !icf.visible
          type = "hidden"
        end
        value = (icf.default_value ? icf.default_value : "")
        mandatory = (icf.is_required ? "true" : "false")

        formitem = {
          key: "cf_#{icf.id}",
          label: icf.name,
          value: value,
          type: type,
          mandatory: mandatory
        }

        if type.end_with?("stringcombo")
          formitem[:values] = {
            items: values
          }
        end

        section[:forms][0][:formitems].append(formitem)
      end
      smash_tags.append(section)
    end
    respond_to do |format|
      format.api { render json: smash_tags }
    end
  end
end
