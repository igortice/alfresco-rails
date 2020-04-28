# frozen_string_literal: true

RSpec.describe AlfrescoRails::File do
  describe 'upload file' do
    let(:alfresco_params) do
      { url_alfresco: ENV['URL_ALFRESCO'], user: ENV['USER_ALFRESCO'], password: ENV['PASSWORD_ALFRESCO'] }
    end

    let(:file) { described_class.new(alfresco_params) }

    context 'with upload success for: filedata, filename, uploaddirectory, containerid, siteid' do
      before do
        file.upload(
          filedata:        File.new('test.pdf'),
          filename:        'filename.pdf',
          uploaddirectory: ENV['UPLOADDIRECTORY'],
          containerid:     ENV['CONTAINERID'],
          siteid:          ENV['SITEID'],
          overwrite:       true
        )
      end

      it 'response code 200' do
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
