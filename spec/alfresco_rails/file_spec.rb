# frozen_string_literal: true

RSpec.describe AlfrescoRails::File do
  let(:alfresco_params) do
    { url_alfresco: ENV['URL_ALFRESCO'], user: ENV['USER_ALFRESCO'], password: ENV['PASSWORD_ALFRESCO'] }
  end
  let(:file) { described_class.new(alfresco_params) }

  describe 'upload file with path' do
    let(:params_upload) do
      {
        filedata:        File.new('test.pdf'),
        filename:        'filename.pdf',
        uploaddirectory: ENV['UPLOADDIRECTORY'],
        containerid:     ENV['CONTAINERID'],
        siteid:          ENV['SITEID'],
        overwrite:       true
      }
    end

    context 'with error upload for: filedata|containerid|siteid' do
      it 'without filedata: code 500 Internal Server Error' do
        file.upload(params_upload.reject { |key| key == :filedata })

        expect(file.response_error.code).to eq(500)
      end

      it 'without containerid: code 400 Bad Request' do
        file.upload(params_upload.reject { |key| key == :containerid })

        expect(file.response_error.code).to eq(400)
      end

      it 'without siteid: code 400 Bad Request' do
        file.upload(params_upload.reject { |key| key == :siteid })

        expect(file.response_error.code).to eq(400)
      end
    end

    context 'with success upload for: filedata, filename, uploaddirectory, containerid, siteid' do
      before do
        file.upload(params_upload)
      end

      it 'response code: 200 Ok' do
        expect(file.response.code).to eq(200)
      end

      it 'response body noderef' do
        expect(file.response.body).to include(:nodeRef)
      end

      it 'response body filename' do
        expect(file.response.body.fileName).to eq(file.payload.filename)
      end
    end
  end

  describe 'upload file with noderef' do
    let(:params_upload) do
      {
        filedata:    File.new('test.pdf'),
        filename:    'filename.pdf',
        destination: ENV['NODEREF_FOLDER_UPLOAD'],
        overwrite:   true
      }
    end

    context 'with error upload for destination' do
      it 'without destination: code 400 Bad Request' do
        file.upload(params_upload.reject { |key| key == :destination })

        expect(file.response_error.code).to eq(400)
      end

      it 'without destination noderef error: code 404 Not Found' do
        params               = params_upload
        params[:destination] = params[:destination] + 'bla'

        file.upload(params)

        expect(file.response_error.code).to eq(404)
      end
    end

    context 'with success upload for: filedata, filename, destination' do
      before do
        file.upload(params_upload)
      end

      it 'response code: 200 Ok' do
        expect(file.response.code).to eq(200)
      end

      it 'response body noderef' do
        expect(file.response.body).to include(:nodeRef)
      end

      it 'response body filename' do
        expect(file.response.body.fileName).to eq(file.payload.filename)
      end
    end
  end
end
