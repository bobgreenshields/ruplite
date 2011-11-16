require 'open4'

class NullLogger
	def initialize
		@absorb = [:info, :debug, :warn, :fatal]
	end

	def method_missing(meth, *args, &blk)
		if @absorb.include? meth
			return nil
		else
			super
		end
	end
end

class Ruplite
	attr_reader :name, :env

	def initialize (name, config, logger = nil)
		@set_envs = []
		@logger = logger || NullLogger.new
		@name = name
		@action = config.has_key?(:action) ? config[:action] : nil
		[:source, :target].each { |inp| define_required_input(inp, config) }
		define_options config
		define_env_vars config
	end

	def define_required_input(name, config)
		if config.has_key? name
# remember #{} calls to_s on subject
			instance_variable_set("@#{name}".to_sym, config[name])
		else
			raise ArgumentError, "the #{name} URL has not been defined"
		end
	end

	def define_options(config)
		@options = ["--name #{@name}"]
		if config.has_key? :options
			config[:options].each do |o|
				if o =~ /--name/
					raise ArgumentError,
						"a --name option should not have been passed"
				end
				@options << o
			end
		end
	end

	def define_env_vars(config)
		@env = {}
		if config.has_key? :env
			config[:env].each { |k, v| @env[k.upcase] = v }
		end
		@env["PASSWORD"] = config[:password] if config.has_key? :password
	end

	def set_systen_env_var(name, value)
#		ENV[name] = value
	end

	def set_env_vars
		@env.each do |k, v|
			@set_envs << k
			set_system_env_var(k, v)
		end
	end

	def reset_env_vars
		@set_envs.each { |k| set_system_env_var(k, "") }
		@set_envs.clear
	end

	def cmd
		cmdarr = ['duplicity']
		cmdarr << @action if @action
		cmdarr << @options.join(" ")
		cmdarr << @source
		cmdarr << @target
		cmdarr.join(" ")
	end

	def run
		out_arr = []
		err_arr = []
		details_arr =[]
		details_arr << "Running duplicity backup called #{@name}"
		details_arr << "calling with #{cmd}"
		details_arr.each { |l| @logger.info l }

		status = Open4::popen4(cmd) do |pid, stdin, stdout, stderr|
			out_arr = stdout.readlines
			err_arr = stderr.readlines
		end

		exit_status = status.exitstatus



	end

end
