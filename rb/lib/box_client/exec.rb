module BoxClient
  class Exec
    TOKEN_URL = 'https://app.box.com/api/oauth2/token'
    STATE = SecureRandom.hex
    DEFAULTS = {
      'port' => 9000,
      'bind' => '127.0.0.1'
    }

    def initialize(config_file, op, export_file)
      return if op == :none
      @config_file = config_file
      @config = YAML.load_file(config_file) || {}
      @op = op
      @export_file = export_file
      set_defaults
      initialize_form
      ensure_tokens
      @client = Boxr::Client.new(@config['access_token'])
      send(@op)
    end

    def setup
    end

    def get
      file = @client.file_from_path("/microsites/#{File.basename(@export_file)}")
      download = @client.download_file(file)
      IO.write(@export_file, download)
    end

    def put
      folder = @client.folder_from_path('/microsites')
      retries = 1
      begin
        file = @client.upload_file(@export_file, folder, preflight_check: false)
      rescue Boxr::BoxrError => e
        raise e if retries < 1
        retries = retries - 1
        file = @client.file_from_path("/microsites/#{File.basename(@export_file)}")
        @client.delete_file(file)
        retry
      end
    end

    def set_defaults
      DEFAULTS.each_pair do |k,v|
        @config[k] ||= v
      end
    end

    def ensure_tokens
      if @config['access_token'].nil?
        STDERR.puts
        STDERR.puts "|====================================================|"
        STDERR.puts "|Getting you an Oauth access token and refresh token.|"
        STDERR.puts "|====================================================|"
        STDERR.puts 
        STDERR.puts "The shib handshake seems to break the token page, so log into box first."
        STDERR.puts "https://umich.app.box.com/files"
        STDERR.puts
        STDERR.puts "I'm starting a WEBrick instance to generate an auth token. Go there next."
        STDERR.puts "http://localhost:9000"
        STDERR.puts
        server = WEBrick::HTTPServer.new(Port: @config['port'], BindAddress: @config['bind'])
        trap 'INT' do server.stop end
        server.mount_proc('/') do |req, res|
          if req.query.has_key?('code') && req.query['state'] == STATE
            params = {
              'grant_type' => 'authorization_code',
              'code' => req.query['code'],
              'client_id' => @config['client_id'],
              'client_secret' => @config['client_secret'],
            }
            uri = URI(TOKEN_URL)
            data = Net::HTTP.post_form(uri, params)
            parsed = JSON.parse(data.body)
            @config['access_token']  = parsed['access_token']
            @config['refresh_token'] = parsed['refresh_token']
            IO.write(@config_file, YAML.dump(@config))
            res.body = "Successfully authenticated. You can close this window/tab."
            Thread.new { sleep(1) ; server.stop }
          else
            res.body = @form
          end
        end
        
        server.start
      else
        params = {
          'grant_type' => 'refresh_token',
          'refresh_token' => @config['refresh_token'],
          'client_id' => @config['client_id'],
          'client_secret' => @config['client_secret'],
        }
        uri = URI(TOKEN_URL)
        data = Net::HTTP.post_form(uri, params)
        parsed = JSON.parse(data.body)
        @config['access_token']  = parsed['access_token']
        @config['refresh_token'] = parsed['refresh_token']
        IO.write(@config_file, YAML.dump(@config))
      end
    end

    def initialize_form
      @form = <<-EOF
<!doctype html>
<html>
  <head></head>
  <body>
    <form action="https://app.box.com/api/oauth2/authorize" method="POST">
       <input type="hidden" name="response_type" value="code">
       <input type="hidden" name="client_id" value="#{@config['client_id']}">
       <input type="hidden" name="state" value="#{STATE}">
       <input type="hidden" name="box_login" value="#{ENV['USER']}@umich.edu">
    </form>
    <script type="text/javascript">
     document.forms[0].submit();
    </script>
  </body>
<html>
      EOF
    end
  end
end

