# frozen_string_literal: true

module AlfrescoRails
  # Class File Alfresco
  #
  #   file = AlfrescoRails::File.new(url_alfresco: '', user: '', password: '')
  #   params = { filedata: File.new('test.pdf'), uploaddirectory: '', containerid: '', siteid: '' }
  #   file.upload(params)
  class File < AlfrescoRails::HttpBase
    PATH_SERVICE_UPLOAD            = 'alfresco/s/api/upload'
    PATH_SERVICE_DELETE_IN_PATH    = 'alfresco/s/slingshot/doclib/action/file/site/%<site>/%<container>/%<path>'
    PATH_SERVICE_DELETE_BY_NODEREF = 'alfresco/s/slingshot/doclib/action/file/node/workspace/SpacesStore/%<id>'

    def upload(
      filedata: nil, filename: nil, destination: nil, updatenoderef: nil, siteid: nil, containerid: nil,
      uploaddirectory: nil, description: nil, contenttype: nil, majorversion: nil, overwrite: false, thumbnails: nil
    )
      payload = {
        filedata: filedata, filename: filename, destination: destination, updatenoderef: updatenoderef,
        siteid: siteid, containerid: containerid, uploaddirectory: uploaddirectory, description: description,
        contenttype: contenttype, majorversion: majorversion, overwrite: overwrite, thumbnails: thumbnails
      }.compact

      config_url_service(path: PATH_SERVICE_UPLOAD)
        .config_payload(payload)
        .process_request_post(content_type: :form_data)
        .obtain_response_object
    end
  end
end
