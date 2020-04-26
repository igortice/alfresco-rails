# frozen_string_literal: true

RSpec.describe AlfrescoRails::HttpBase do
  let(:http_base) { described_class.new(url_alfresco: 'http://url_alfresco', user: 'user', password: 'password') }

  it 'construct required: url_alfresco, user, password' do
    expect { described_class.new }.to raise_error('missing keywords: url_alfresco, user, password')
  end

  it 'construct without valid url_alfresco' do
    base = described_class.new(url_alfresco: 'url_alfresco', user: 'user', password: 'password')
    expect(base).to have_attributes(http_base_errors: ["url_alfresco: #{base.url_alfresco}"])
  end

  it 'construct with valid url_alfresco' do
    expect(http_base).to have_attributes(http_base_errors: [])
  end

  it 'config_url_service: config path' do
    http_base.config_url_service(path: '/url_service')

    expect(http_base.uri.to_s).to eq(http_base.url_service)
  end

  it 'config_url_service: config query' do
    http_base.config_url_service(query: 'id=30&limit=5')

    expect(http_base.uri.to_s).to eq(http_base.url_service)
  end

  it 'config_url_service: config fragment' do
    http_base.config_url_service(fragment: 'time=1305298413')

    expect(http_base.uri.to_s).to eq(http_base.url_service)
  end

  it 'config_payload: config payload hash' do
    payload = { username: 'username', password: 'password' }
    http_base.config_payload(payload)

    expect(http_base.payload).to have_attributes(**payload)
  end
end
