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
		@env = {}
		@name = name
#		@config = config
		@action = config.has_key?(:action) ? config[:action] : nil
		if config.has_key? :source
			@source = config[:source]
		end
		if config.has_key? :target
			@target = config[:target]
		end
		@logger = logger || NullLogger.new
		@options = ["--name #{@name}"]
		if config.has_key? :options
			config[:options].each { |o| @options << o }
		end
		define_env_vars config
	end

	def define_env_vars(config)
		if config.has_key? :env
			config[:env].each { |k, v| @env[k.upcase] = v }
		end
		@env["PASSWORD"] = config[:password] if config.has_key? :password
	end

	def cmd
		cmdarr = ['duplicity']
		cmdarr << @action if @action

		cmdarr << @options.join(" ")

		cmdarr << @source
		cmdarr << @target

		cmdarr.join(" ")
	end
end
