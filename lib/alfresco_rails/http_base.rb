# frozen_string_literal: true

require 'rest-client'
require 'recursive-open-struct'
require 'json'

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
      @password         = password.to_s
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

      @payload = RecursiveOpenStruct.new(payload)

      self
    end

    # Process Request Get
    #
    # @return [HttpBase] self
    def process_request_get
      begin_rescue do
        config_url_service if @url_service.nil?
        @response = @request.get
      end

      self
    end

    # Process Request Post
    #
    # @return [HttpBase] self
    def process_request_post(content_type: :json)
      begin_rescue do
        config_url_service if @url_service.nil?
        config_payload({}) if payload.nil?
        payload   = @payload.marshal_dump
        @response =
          case content_type
          when :json
            @request.post(payload.to_json, content_type: content_type)
          when :form_data
            @request.post(payload)
          else
            @request.post(payload, content_type: content_type)
          end
      end

      self
    end

    # Process Request Post Json
    #
    # @return [HttpBase] self
    def process_request_post_json
      begin_rescue do
        config_url_service if @url_service.nil?
        config_payload({}) if payload.nil?
        @response = @request.post(@payload.marshal_dump.to_json, content_type: :json)
      end

      self
    end

    def process_request_delete
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

    # Obtain Response Object
    #
    # @return [Boolean|RecursiveOpenStruct] false|@response
    def obtain_response_object
      return false unless @response_error.nil?

      begin_rescue do
        code      = @response.code
        body      = JSON.parse(@response, symbolize_names: true, object_class: RecursiveOpenStruct)
        @response = RecursiveOpenStruct.new({ code: code, body: body })
      end
    end

    def begin_rescue
      throw(@http_base_errors) unless @http_base_errors.empty?

      yield
    rescue RestClient::ExceptionWithResponse => e
      @response_error =
        RecursiveOpenStruct.new({ code: e.response.code, name: e.to_s, description: e.response.body })
    rescue StandardError => e
      @response_error =
        RecursiveOpenStruct.new({ code: 500, name: '500 Internal Server Error', description: e.message })
    end
  end
end
