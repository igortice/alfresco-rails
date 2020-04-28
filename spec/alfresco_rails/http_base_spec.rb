# frozen_string_literal: true

RSpec.describe AlfrescoRails::HttpBase do
  let(:http_base) { described_class.new(url_alfresco: 'http://url_alfresco', user: 'user', password: 'password') }
  let(:http_base_postman) do
    described_class.new(url_alfresco: 'https://postman-echo.com', user: 'user', password: 'password')
  end

  context 'when constructor' do
    it 'required: url_alfresco, user, password' do
      expect { described_class.new }.to raise_error('missing keywords: url_alfresco, user, password')
    end

    it 'without valid url_alfresco' do
      base = described_class.new(url_alfresco: 'url_alfresco', user: 'user', password: 'password')
      expect(base).to have_attributes(http_base_errors: ["url_alfresco: #{base.url_alfresco}"])
    end

    it 'with valid url_alfresco' do
      expect(http_base).to have_attributes(http_base_errors: [])
    end
  end

  context 'when config_url_service' do
    it 'config path' do
      http_base.config_url_service(path: '/url_service')

      expect(http_base.uri.to_s).to eq(http_base.url_service)
    end

    it 'config query' do
      http_base.config_url_service(query: 'id=30&limit=5')

      expect(http_base.uri.to_s).to eq(http_base.url_service)
    end

    it 'config fragment' do
      http_base.config_url_service(fragment: 'time=1305298413')

      expect(http_base.uri.to_s).to eq(http_base.url_service)
    end
  end

  context 'when config_payload' do
    it 'config payload hash' do
      payload = { username: 'username', password: 'password' }
      http_base.config_payload(payload)

      expect(http_base.payload).to have_attributes(**payload)
    end
  end

  context 'when process_request_get' do
    it 'with status code 500' do
      http_base
        .config_url_service(path: 'posts')
        .process_request_get

      expect(http_base.response_error.code).to eq(500)
    end

    it 'with status code 200' do
      http_base_postman
        .config_url_service(path: 'get')
        .process_request_get

      expect(http_base_postman.response.code).to eq(200)
    end
  end

  context 'when process_request_post' do
    it 'with status code 404' do
      http_base_postman
        .config_url_service(path: '/posts')
        .process_request_post

      expect(http_base_postman.response_error.code).to eq(404)
    end

    it 'with status code 200' do
      http_base_postman
        .config_url_service(path: '/post')
        .process_request_post

      expect(http_base_postman.response.code).to eq(200)
    end
  end

  context 'when obtain_response_object' do
    let(:http_base_postman_error) { http_base_postman.dup }

    before do
      http_base_postman
        .config_url_service(path: '/post')
        .config_payload({ key: 'value' })
        .process_request_post
        .obtain_response_object
    end

    it 'with status result false' do
      result_error =
        http_base_postman_error
        .config_url_service(path: '/posts')
        .process_request_post
        .obtain_response_object

      expect(result_error).to eq(false)
    end

    it 'with status code 404' do
      http_base_postman_error
        .config_url_service(path: '/posts')
        .process_request_post
        .obtain_response_object

      expect(http_base_postman_error.response_error.code).to eq(404)
    end

    it 'with status code 200' do
      expect(http_base_postman.response.code).to eq(200)
    end

    it 'with status result object' do
      expect(http_base_postman.response.body.data.to_hash).to eq({ key: 'value' })
    end
  end
end
