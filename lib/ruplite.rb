require 'open4'

class NullLogger
	def initialize
		@absorb = [:info, :debug, :error, :warn, :fatal]
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
		@env["PASSPHRASE"] = config[:passphrase] if config.has_key? :passphrase
	end

	def set_system_env_var(name, value)
#		ENV[name] = value
		`export #{name}=#{value}`
	end

#	def set_env_vars
#		@env.each do |k, v|
#			@set_envs << k
#			set_system_env_var(k, v)
#		end
#	end

#	def reset_env_vars
#		@set_envs.each { |k| set_system_env_var(k, "") }
#		@set_envs.clear
#	end

	def cmd
		cmdarr = ['duplicity']
		cmdarr << @action if @action
		cmdarr << @options.join(" ")
		cmdarr << @source
		cmdarr << @target
		cmdarr.join(" ")
	end

	def run_cmd
		res = {:out => [], :err => []}
		status = Open4::popen4("sh") do |pid, stdin, stdout, stderr|
			@env.each do |k, v|
				stdin.puts "echo \"exporting #{k}\""
				stdin.puts "export #{k}=#{v}"
			end
			stdin.puts "echo \"running #{cmd}\""
			stdin.puts cmd
			@env.each_key do |k|
				stdin.puts "echo \"unsetting #{k}\""
				stdin.puts "unset #{k}"
			end
			stdin.close
			stdout.readlines.each { |l| res[:out] << l.strip }
			stderr.readlines.each { |l| res[:err] << l.strip }
		end
		res[:exit_status] = status.exitstatus
		res
	end

	def run
		details_arr =[]
		details_arr << "Running duplicity backup called #{@name}"
		details_arr << "calling with #{cmd}"
#		details_arr.each { |l| @logger.info l }

		runinfo = run_cmd

		details_arr = details_arr + runinfo[:out]
		if runinfo[:err].length > 0
			details_arr << "**** Stderr ****"
			details_arr = details_arr + runinfo[:err]
		end

		runinfo[:out].each { |l| @logger.info l }
		runinfo[:err].each { |l| @logger.error l }

		s = "Exit status was #{runinfo[:exit_status]}"
		if runinfo[:exit_status] = 0
			@logger.info s
		else
			@logger.error s
		end
		details_arr << s

		@run_info = details_arr.join("\n")
	end

end
