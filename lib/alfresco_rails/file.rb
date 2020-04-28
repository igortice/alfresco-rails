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

    # upload
    #   filedata, (mandatory) HTML type file
    #   filename (optional)
    #   You must specify one of:
    #     destination (the folder NodeRef where the node will be created)
    #     updateNodeRef (the NodeRef of an existing node that will be updated)
    #     siteid and containerid (the Site name and the container in that site where the document will be created)
    #   containerid (documentLibrary)
    #   uploaddirectory - name of the folder (either in the site container or the destination)
    #                     where the document will be uploaded. This folder must already exist
    #   description - Description for a version update (versionDescription)
    #   contenttype - The content type that this document should be specialised to
    #   majorversion
    #   overwrite
    #   thumbnails
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
