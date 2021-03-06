class SmashTagsController < ApplicationController

  before_action :find_project_by_project_id
  before_action :authorize

  accept_api_auth :index

  def index
    smash_tags = []
    # Issue priorities
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
    # Issue categories
    categories = []
    @project.issue_categories.each do |category|
      categories.append({
        item: category.name
      })
    end
    # Versions
    versions = []
    default_version = nil
    @project.versions.each do |version|
      versions.append({
        item: version.name
      })
    end
    if @project.default_version.present?
      default_version = @project.default_version.name
    end
    # Trackers
    @project.trackers.sort.each do |tracker|
      section = {
        sectionname: tracker.name,
        sectiondescription: tracker.description,
        sectionicon: "image",
        forms: [{
          formname: tracker.name,
          formitems: [
            # Core fields (undisablable)
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
            }
          ]
        }]
      }
      formitems = section[:forms][0][:formitems]
      # Standard (core) fields
      if tracker.core_fields.present?
        # assigned_to_id (don't support)
        # category_id
        if tracker.core_fields.include?("category_id")
          formitems.append({
            key: "category_id",
            label: l(:field_category),
            values: {
              items: categories
            },
            value: "",
            type: "stringcombo",
            # mandatory: "yes"
          })
        end
        # fixed_version_id
        if tracker.core_fields.include?("fixed_version_id")
          formitems.append({
            key: "fixed_version_id",
            label: l(:field_version),
            values: {
              items: versions
            },
            value: default_version,
            type: "stringcombo",
            # mandatory: "yes"
          })
        end
        # parent_issue_id (don't support)
        # start_date
        if tracker.core_fields.include?("start_date")
          formitems.append({
            key: "start_date",
            label: l(:field_start_date),
            value: "",
            type: "date"
          })
        end
        # due_date
        if tracker.core_fields.include?("due_date")
          formitems.append({
            key: "due_date",
            label: l(:field_due_date),
            value: "",
            type: "date"
          })
        end
        # estimated_hours
        if tracker.core_fields.include?("estimated_hours")
          formitems.append({
            key: "estimated_hours",
            label: l(:field_estimated_hours),
            value: "",
            type: "integer"
          })
        end
        # done_ratio
        if tracker.core_fields.include?("done_ratio")
          done_ratios = []
          0.step(100, 10) {|ratio|
            done_ratios.append({
              item: "#{ratio} %"
            })
          }
          formitems.append({
            key: "done_ratio",
            label: l(:field_done_ratio),
            values: {
              items: done_ratios
            },
            value: "0 %",
            type: "stringcombo"
          })
        end
        # description
        if tracker.core_fields.include?("description")
          formitems.append({
            key: "description",
            label: l(:field_description),
            value: "",
            type: "string"
          })
        end
      end
      # Attachments
      formitems.append({
        key: "attachments",
        value: "",
        type: "pictures"
      })
      # IssueCustomField mapping
      # Redmine: https://github.com/redmine/redmine/blob/master/lib/redmine/field_format.rb
      tracker.custom_fields.each do |icf|
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

        formitems.append(formitem)
      end
      smash_tags.append(section)
    end
    respond_to do |format|
      format.api { render json: smash_tags }
    end
  end
end
