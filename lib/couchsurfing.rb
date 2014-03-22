class CouchSurfing
  CONFIG_PATH = 'config/couchsurfing.yml'

  def self.instance
    # TODO: cache cookie somewhere so we don't have to sign in all the time
    cs = CouchSurfingClient::CouchSurfing.new(credentials['username'], credentials['password'])
    cs.sign_in
    cs
  end

  def self.credentials
    return env_credentials if env_credentials
    config
  end

  def self.env_credentials
    if ENV.key?('CS_USERNAME') && ENV.key?('CS_PASSWORD')
      {
        'username' => ENV['CS_USERNAME'],
        'password' => ENV['CS_PASSWORD']
      }
    end
  end

  def self.config
    conf = fetch_config
    check_config conf
    conf
  end

  def self.fetch_config
    conf = YAML.load File.read(Rails.root.join(CONFIG_PATH))
  end

  def self.check_config conf
    %w(username password).each do |param|
      fail "#{param} is not defined in #{CONFIG_PATH}" unless conf.key? param
    end
  end

end
