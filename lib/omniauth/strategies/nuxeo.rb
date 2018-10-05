require 'securerandom'
require 'omniauth-oauth2'

# OmniAuth strategy for connecting to the Nuxeo system via the OAuth 2.0 protocol
module OmniAuth

  module Strategies

    class Nuxeo < OmniAuth::Strategies::OAuth2

      option :name, "nuxeo"

      CLIENT_OPTIONS = [
        :site
      ]

      AUTHORIZATION_OPTIONS = [
        :response_type,
        :redirect_uri,
        :state,
        :code_challenge,
        :code_challenge_method
      ]

      TOKEN_OPTIONS = [
        :grant_type,
        :code,
        :redirect_uri,
        :code_verifier
      ]

      option :authorization_options, AUTHORIZATION_OPTIONS
      option :token_options, TOKEN_OPTIONS

      # Bypass CSRF errors
      # We should remove this and solve the issue properly if going live
      option :provider_ignores_state, true

      args [:client_id, :client_secret]

      def initialize(app, *args, &block)
        super
        @options.client_id = args[0][:client_id] || "ABCDEFG"
        @options.client_secret = args[0][:client_secret] || "1234567890"
        @options.client_options.site = args[0][:site] || "https://tester.nuxeo.org"
        @options.client_options.authorize_url = "#{args[0][:site]}/nuxeo/oauth2/authorize"
        @options.client_options.token_url = "#{args[0][:site]}/nuxeo/oauth2/token"

        @options.client_options.code_challenge_method = "S256"
        @options.client_options.code_challenge = SecureRandom.base64(256)
      end

      uid { raw_info['id'] }

      info do
        {
          'response' => raw_info,
          'email' => raw_info['email']
        }
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        hash
      end

      def authorize_params
        super.tap do |params|
          params[:client_secret] = @options.client_secret
          #params[:code_challenge_method] = @options.client_options.code_challenge_method
          #params[:code_challenge] = @options.client_options.code_challenge
        end
      end

      def token_params
        super.tap do |params|
p "TOKEN CHECK #{ @env['omniauth.params'].inspect }"
        end
      end

      def callback_phase
        request.params["grant_type"] = "authorization_code"
        request.params["client_id"] = @options.client_id
      end

      private

      def raw_info
        @raw_info ||= access_token.get('me', info_options).parsed || {}
      end

    end

  end

end
