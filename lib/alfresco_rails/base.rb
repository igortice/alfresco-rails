# frozen_string_literal: true
require 'rest-client'

module AlfrescoRails
  class Base
    attr_accessor :url_alfresco, :url_alfresco_error, :url_service, :user, :password, :payload, :request, :response, :response_error

    def initialize(url_alfresco:, user:, password:)
      uri           = URI.parse(url_alfresco.to_s)
      @url_alfresco = url_alfresco
      if uri.kind_of?(URI::HTTP) or uri.kind_of?(URI::HTTPS)
        @url_alfresco_error = nil
      else
        @url_alfresco_error = @url_alfresco
      end
      @url_service    = nil
      @user           = user.to_s
      @password       = password
      @payload        = nil
      @request        = nil
      @response       = nil
      @response_error = nil
    end

    def config_url_service(url_service)
      return self unless @url_alfresco_error.nil?

      url_service  = url_service.split('/').reject(&:empty?).join('/')
      @url_service = "#{@url_alfresco}/#{url_service}"
      @request     = RestClient::Resource.new @url_service, @user, @password

      self
    end

    def config_payload(payload)
      return self unless @url_alfresco_error.nil?

      @payload = OpenStruct.new(payload)

      self
    end

    def send_request_get
      return self unless @url_alfresco_error.nil?

      @response_error = nil
      @response       = @request.get

      self
    end

    def send_request_post
      return self unless @url_alfresco_error.nil?

      @response_error = nil
      @response       = @request.post(@payload.marshal_dump)

      self
    end

    def send_request_post_json
      return self unless @url_alfresco_error.nil?

      @response_error = nil
      @response       = @request.post(@payload.marshal_dump.to_json, content_type: :json)

      self
    end

    def send_request_delete
      return self unless @url_alfresco_error.nil?

      @response_error = nil
      @response       = @request.delete

      self
    end

    def get_response
      return self unless @url_alfresco_error.nil?

      @response
    end

    def get_response_json
      return self unless @url_alfresco_error.nil?

      @response = JSON.parse(@response, symbolize_names: true)
    end

    def get_response_object
      return self unless @url_alfresco_error.nil?

      @response = JSON.parse(@response, object_class: OpenStruct)
    end

    def begin_rescue(accessors = [])
      throw("url alfresco invalid: #{@url_alfresco_error}") unless @url_alfresco_error.nil?

      yield
    rescue RestClient::ExceptionWithResponse => e_rc
      begin
        @response_error = JSON.parse(e_rc.response, object_class: OpenStruct)
      rescue JSON::ParserError
        @response_error = OpenStruct.new({ status: { code: e_rc.http_code, name: e_rc.to_s, description: e_rc.response.body } })
      end
      accessors.each { |var| self.instance_variable_set(var, nil) }
      @response = nil

      false
    rescue => e
      @response_error = OpenStruct.new({ status: { code: 500, name: 'Internal Server Error', description: e.message } })
      accessors.each { |var| self.instance_variable_set(var, nil) }
      @response = nil

      false
    end
  end
end
