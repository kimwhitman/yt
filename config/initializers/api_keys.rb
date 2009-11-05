# Default production values
ENV['organization_id'] ||= '35cead0a66324a428fba2a4117707165'
ENV['api_domain'] ||= 'api.delvenetworks.com/rest'
REMOTE_ORG_ENDPOINT = "http://#{ENV['api_domain']}/organizations/#{ENV['organization_id']}"
REMOTE_MEDIA_ENDPOINT = "#{REMOTE_ORG_ENDPOINT}/media.json"
DELVE_API_ACCESS_KEY = '1L/+Lw0fXZea1GpNBbFwEh16LjY=';
DELVE_API_SECRET = 'DFjH8vZfzTQ/kkL7cYK9hc2gPP0='