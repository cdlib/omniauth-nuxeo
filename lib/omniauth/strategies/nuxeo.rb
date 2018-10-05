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

      args [:client_id, :client_secret]

      def initialize(app, *args, &block)
        super
        @options.client_id = args[0][:client_id] || "ABCDEFG"
        @options.client_secret = args[0][:client_secret] || "1234567890"
        @options.client_options.site = args[0][:site] || "https://tester.nuxeo.org"
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

      def authorize_url
        "#{root_url}/nuxeo/oauth2/authorize"
      end

      def token_url
        "#{root_url}/token"
      end

=begin
      def authorize_params
        super.tap do |params|
          params[:response_type] = "code"

          AUTHORIZATION_OPTIONS.each do |opt|
            params[opt] = request.params[opt] if request.params[opt].present?
          end

          session['omniauth.state'] = params[:state] if params['state']
        end
      end
=end
    end

  end

end
