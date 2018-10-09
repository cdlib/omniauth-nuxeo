require 'securerandom'
require 'omniauth-oauth2'

# OmniAuth strategy for connecting to the Nuxeo system via the OAuth 2.0 protocol
# Refer to the Nuxeo documentation for further details:
#    https://doc.nuxeo.com/910/nxdoc/using-oauth2/#oauth-2-flow
#    https://doc.nuxeo.com/910/nxdoc/rest-api-endpoints/
module OmniAuth

  module Strategies

    class Nuxeo < OmniAuth::Strategies::OAuth2

      option :name, "nuxeo"

      REDIRECT_URL = "http://localhost:3000/auth/nuxeo/callback"
      AUTHORIZE_PATH = "/nuxeo/oauth2/authorize"

      # The CDL Nuxeo implementation has redirect logic to send lower case
      # 'nuxeo' traffic to Shibboleth, so we need to us camel case for token
      # and other urls once the user has auth'ed through their Shib IdP
      TOKEN_PATH = "/Nuxeo/oauth2/token"

      API_BASE_PATH = "/nuxeo/api/v1"
      REQUEST_USER_PATH = "#{API_BASE_PATH}/user"

      CLIENT_OPTIONS = [
        :site
      ]

      option :authorization_options, [
        :response_type,
        :redirect_uri,
        :state,
        :code_challenge,
        :code_challenge_method
      ]

      option :token_options, [
        :grant_type,
        :code,
        :redirect_uri,
        :code_verifier
      ]

      # Bypass CSRF errors
      # We should remove this and solve the issue properly if going live
      option :provider_ignores_state, true

      args [:client_id, :client_secret]

      def initialize(app, *args, &block)
        super
        if args[0].present?
          @options.client_id = args[0].fetch(:client_id, "ABCDEFG")
          @options.client_secret = args[0].fetch(:client_secret, "1234567890")

          site = args[0].fetch(:site, "https://tester.nuxeo.org")
          @options.client_options.site = site
          @options.client_options.authorize_url = "#{site}#{AUTHORIZE_PATH}"
          @options.client_options.token_url = "#{site}#{TOKEN_PATH}"
          @options.client_options.request_url = "#{site}#{REQUEST_USER_PATH}"

          @options.client_options.redirect_uri = REDIRECT_URL
          @options.client_options.code_challenge_method = "S256"
          @options.client_options.code_challenge = SecureRandom.base64(256)
        end
      end

      uid { access_token.token }

      info do
        {
          email: raw_info[:email],
          first_name: raw_info[:first_name],
          last_name: raw_info[:last_name]
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def request_info
        target = "#{@options.client_options.request_url}/#{uid}"
        @request_info ||= client.request(:get, target, headers: { accept: 'application/json' }).parsed || {}
      end

      private

      # retrieve all verified email addresses and include visibility (LIMITED vs. PUBLIC)
      # and whether this is the primary email address
      # all other information will in almost all cases be PUBLIC
      def raw_info
        json = request_info

        p "RAW INFO: #{json.inspect}"

        @raw_info ||= {
          first_name: json.fetch('given-names', ''),
          last_name: json.fetch('sur-name', ''),
          email: json.fetch('email', '')
        }
      end

    end

  end

end
