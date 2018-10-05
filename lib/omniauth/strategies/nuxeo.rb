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
        @options.client_options.token_url = "#{args[0][:site]}/token"
      end

      uid { raw_info["code"] }

      info do
        {
          name: raw_info["name"],
          email: raw_info["email"]
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/me").parsed
      end

    end

  end

end
