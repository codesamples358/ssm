module Ssm
  class Api
    URL_BASE = 'https://screenshotmonitor.com/api/v2'
    TOKEN    = ENV['SSM_API_TOKEN']

    delegate :get, :post, to: RestClient

    def call(rel_url, params = {})
      headers  = {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json',

        'X-SSM-Token'  => TOKEN
      }

      body = params.to_json

      full_url = url rel_url
      response = post(full_url, body, headers)
      JSON(response)
    end

    def url(relative_url)
      URL_BASE + '/' + relative_url
    end

    def common_data
      call 'GetCommonData'
    end

    def activities(request_opts)
      call 'GetActivities', [ request_opts ]
    end

    def companies
      common_data['companies']
    end

    def company
      companies[0]
    end

    def projects
      company['projects']
    end

    def employments
      company['employments']
    end
  end
end