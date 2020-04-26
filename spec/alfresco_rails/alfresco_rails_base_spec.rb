# frozen_string_literal: true

RSpec.describe AlfrescoRails::Base do
  let(:base_new) { AlfrescoRails::Base.new(url_alfresco: 'http://url_alfresco', user: 'user', password: 'password') }

  it 'construct required: url_alfresco, user, password' do
    expect { AlfrescoRails::Base.new }.to raise_error('missing keywords: url_alfresco, user, password')
  end

  it 'construct without valid url_alfresco' do
    base = AlfrescoRails::Base.new(url_alfresco: 'url_alfresco', user: 'user', password: 'password')
    expect(base).to have_attributes(url_alfresco_error: base.url_alfresco)
  end

  it 'construct with valid url_alfresco' do
    expect(base_new).to have_attributes(url_alfresco_error: nil)
  end

  it 'config_url_service: set url_service' do
    url_service = '/url_service'
    result      = base_new.url_alfresco + url_service
    base_new.config_url_service('/url_service')
    expect(base_new.url_service).to eq(result)
  end
end
