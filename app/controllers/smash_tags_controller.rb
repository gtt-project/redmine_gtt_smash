class SmashTagsController < ApplicationController

  before_action :find_project_by_project_id
  before_action :authorize

  accept_api_auth :index

  def index
    example = [{
      sectionname: "[GTT] Task note",
      sectiondescription: "GTT task with image",
      sectionnicon: "image",
      forms: [
        {
          formname: "Take a photo",
          formitems: [
            {
              key: "title",
              islabel: "true",
              value: "",
              icon: "infoCircle",
              type: "string",
              mandatory: "yes"
            }
          ]
        }
      ]
    }]
    respond_to do |format|
      format.api { render json: example }
    end
  end
end
