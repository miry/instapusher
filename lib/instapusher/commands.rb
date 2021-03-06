require 'net/http'
require 'uri'
require 'multi_json'
require 'instapusher'

module Instapusher
  class Commands
    DEFAULT_HOSTNAME = 'instapusher.com'

    def self.deploy(project_name=nil, branch_name=nil)

      hostname = ENV['INSTAPUSHER_HOST'] || DEFAULT_HOSTNAME
      hostname = "localhost:3000" if ENV['LOCAL']

      url          = "http://#{hostname}/heroku.json"
      git          = Git.new
      branch_name  ||= git.current_branch
      project_name ||= git.project_name

      api_key = Instapusher::Configuration.api_key || ""
      if api_key.to_s.length == 0
        puts "Please enter instapusher api_key at ~/.instapusher "
      end

      options = { project: project_name,
                  branch:  branch_name,
                  local:   ENV['LOCAL'],
                  api_key: api_key }

      response = Net::HTTP.post_form URI.parse(url), options
      response_body  = MultiJson.load(response.body)
      job_status_url = response_body['status'] || response_body['job_status_url']

      if job_status_url && job_status_url != ""
        puts 'The appliction will be deployed to: ' + response_body['heroku_url']
        puts 'Monitor the job status at: ' + job_status_url
        cmd = "open #{job_status_url}"
        `#{cmd}`
      else
        puts response_body['error']
      end
    end
  end
end
