module BoxClient
  class Cmd
    DEFAULTS = {
      config_file: "box-config.yml",
      export_file: "#{ENV['USER']}.microsites.sql.gz"
    }.freeze

    def initialize
      set_defaults
      init_opts
      process_opts
      @exec = BoxClient::Exec.new(@config_file, @op, @export_file)
    end

    private
    def process_opts
      @opts.each do |opt, arg|
        case opt
        when '--help'
          @op = :none
          show_help
        when '--config'
          @config_file = arg
        end
      end

      case ARGV.shift
      when 'setup'
        @op = :setup
      when 'put'
        @op = :put
      when 'get'
        @op = :get
      else
        @op = :none
      end
    
      @export_file = ARGV.shift
    end

    def show_help
      puts <<-EOF
usage: ...
      EOF
    end

    def set_defaults
      @config_file = DEFAULTS[:config_file]
      @export_file = DEFAULTS[:export_file]
    end

    def init_opts
      @opts = GetoptLong.new(
        ['--help', '-h', GetoptLong::NO_ARGUMENT],
        ['--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
      )
    end

  end
end
