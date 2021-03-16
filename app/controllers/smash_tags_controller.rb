class SmashTagsController < ApplicationController

  before_action :find_optional_project_and_authorize

  accept_api_auth :project_tags, :global_tags

  def project_tags
    smash_tags = build_tags
    respond_to do |format|
      format.api { render json: smash_tags }
    end
  end

  def global_tags
    smash_tags = build_tags
    respond_to do |format|
      format.api { render json: smash_tags }
    end
  end

  private

  def find_optional_project_and_authorize
    if params[:project_id]
      @project = Project.find params[:project_id]
      authorize
    else
      authorize_global
    end
  end

  def enabled_project_ids
    EnabledModule.where(name: ['issue_tracking', 'gtt', 'gtt_smash']).
      group(:project_id).
      count('project_id').
      keep_if {|k,v| v == 3}.keys
  end

  def valid_project_ids
    project_ids = []
    Project.where(status: "#{Project::STATUS_ACTIVE}").
      where(id: enabled_project_ids()).
      where(id: User.current.visible_project_ids).sort.each {|project|
        if User.current.allowed_to?(:add_issues, project) and
          User.current.allowed_to?(:view_gtt_smash, project)
          project_ids.append(project.id)
        end
      }
    return project_ids
  end

  def valid_tracker_project_ids
    tracker_project_ids = {}
    valid_project_ids = valid_project_ids()
    project_ids = []
    if @project.present? and valid_project_ids.include?(@project.id)
      project_ids.append(@project.id)
    else
      project_ids.concat(valid_project_ids)
    end
    Project.where(id: project_ids).each {|project|
      project.trackers.each {|tracker|
        if tracker_project_ids.has_key?(tracker.id)
          tracker_project_ids[tracker.id].append(project.id)
        else
          tracker_project_ids[tracker.id] = [project.id]
        end
      }
    }
    return tracker_project_ids
  end

  # SMASH (Geopaparazzi) form spec: https://www.geopaparazzi.org/geopaparazzi/index.html#_using_form_based_notes
  def build_tags
    smash_tags = []
    # Issue priorities
    priorities = []
    default_priority = nil
    IssuePriority.active.each do |priority|
      priorities.append({
        item: {
          label: priority.name,
          value: priority.id.to_s
        }
      })
      if priority.is_default
        default_priority = priority.id.to_s
      end
    end
    # Issue categories
    categories = []
    if @project.present?
      @project.issue_categories.each do |category|
        categories.append({
          item: {
            label: category.name,
            value: category.id.to_s
          }
        })
      end
    end
    # Versions
    versions = []
    default_version = nil
    if @project.present?
      @project.versions.each do |version|
        versions.append({
          item: {
            label: version.name,
            value: version.id.to_s
          }
        })
      end
      if @project.default_version.present?
        default_version = @project.default_version.id
      end
    end
    # Trackers
    tracker_project_ids = valid_tracker_project_ids()
    Tracker.where(id: tracker_project_ids.keys).sort.each do |tracker|
      # Projects
      project_ids = tracker_project_ids[tracker.id]
      projects = []
      if @project.blank? and project_ids.present?
        Project.where(id: project_ids).sort.each {|project|
          projects.append({
            item: {
              label: project.name,
              value: project.id.to_s
            }
          })
        }
      end
      section = {
        sectionname: tracker.name,
        sectiondescription: "GTT",
        sectionicon: "image",
        forms: [{
          formname: tracker.name,
          formitems: [
            # Core fields (undisablable)
            {
              key: "project_id",
              label: l(:field_project),
              value: @project.present? ? @project.id.to_s : "",
              values: @project.present? ? nil : { items: projects },
              type: @project.present? ? "hidden" : "stringcombo",
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
        if tracker.core_fields.include?("category_id") and categories.present?
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
        if tracker.core_fields.include?("fixed_version_id") and versions.present?
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
              item: {
                label: "#{ratio} %",
                value: ratio.to_s
              }
            })
          }
          formitems.append({
            key: "done_ratio",
            label: l(:field_done_ratio),
            values: {
              items: done_ratios
            },
            value: "0",
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
    return smash_tags
  end
end
