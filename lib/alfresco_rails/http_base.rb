# frozen_string_literal: true

require 'rest-client'
require 'ostruct'

module AlfrescoRails
  # Class HttpBase
  #   http_base = AlfrescoRails::HttpBase.new(url_alfresco: 'http://url_alfresco', user: 'user', password: 'password')
  #
  #   http_base.config_url_service(path: nil, query: nil, fragment: nil)
  #   http_base.config_payload({key: 'value'})
  class HttpBase
    attr_accessor :uri, :url_alfresco, :http_base_errors, :url_service,
                  :user, :password, :payload, :request, :response, :response_error

    def initialize(url_alfresco:, user:, password:)
      @uri              = URI(url_alfresco.to_s)
      @url_alfresco     = @uri.to_s
      @http_base_errors = []
      @url_service      = nil
      @user             = user.to_s
      @password         = password
      @payload          = nil
      @request          = nil
      @response         = nil
      @response_error   = nil

      @http_base_errors << "url_alfresco: #{@url_alfresco}" unless @uri.is_a?(URI::HTTP) || @uri.is_a?(URI::HTTPS)
    end

    # Config path, query and fragment from uri
    #
    # @param [String] 'path'
    # @param [String] 'query'
    # @param [String] 'fragment'
    # @return [HttpBase] self
    def config_url_service(path: nil, query: nil, fragment: nil)
      return self unless @http_base_errors.empty?

      @uri.path     = '/' + path.split('/').reject(&:empty?).join('/') if path
      @uri.query    = query if query
      @uri.fragment = fragment if fragment

      @url_service = @uri.to_s
      @request     = RestClient::Resource.new @url_service, @user, @password

      self
    end

    # Config payload
    #
    # @param [Hash] 'payload'
    # @return [HttpBase] self
    def config_payload(payload)
      return self unless @http_base_errors.empty?

      @payload = OpenStruct.new(payload)

      self
    end

    def send_request_get
      return self unless @http_base_errors.empty?

      @response_error = nil
      @response       = @request.get

      self
    end

    def send_request_post
      return self unless @http_base_errors.empty?

      @response_error = nil
      @response       = @request.post(@payload.marshal_dump)

      self
    end

    def send_request_post_json
      return self unless @http_base_errors.empty?

      @response_error = nil
      @response       = @request.post(@payload.marshal_dump.to_json, content_type: :json)

      self
    end

    def send_request_delete
      return self unless @http_base_errors.empty?

      @response_error = nil
      @response       = @request.delete

      self
    end

    def obtain_response
      return self unless @http_base_errors.empty?

      @response
    end

    def obtain_response_json
      return self unless @http_base_errors.empty?

      @response = JSON.parse(@response, symbolize_names: true)
    end

    def obtain_response_object
      return self unless @http_base_errors.empty?

      @response = JSON.parse(@response, object_class: OpenStruct)
    end

    def begin_rescue(accessors = [])
      throw(@http_base_errors) unless @http_base_errors.empty?

      yield
    rescue RestClient::ExceptionWithResponse => e
      begin
        @response_error = JSON.parse(e.response, object_class: OpenStruct)
      rescue JSON::ParserError
        @response_error = OpenStruct.new({ status: { code: e.http_code, name: e.to_s, description: e.response.body } })
      end
      accessors.each { |var| instance_variable_set(var, nil) }
      @response = nil

      false
    rescue StandardError => e
      @response_error = OpenStruct.new({ status: { code: 500, name: 'Internal Server Error', description: e.message } })
      accessors.each { |var| instance_variable_set(var, nil) }
      @response = nil

      false
    end
  end
end
