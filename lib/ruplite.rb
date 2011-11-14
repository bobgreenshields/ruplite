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
	attr_reader :name

	def initialize (name, config, logger = nil)
		@env = []
		@name = name
		@config = config
		@logger = logger || NullLogger.new
		@options = ["--name #{@name}"]
		if config.has_key? :options
			config[:options].each { |o| @options << o }
		end
	end

	def cmd
		cmdarr = ['duplicity']
		cmdarr << @config[:action] if @config.has_key? :action

		cmdarr << @options.join(" ")

		cmdarr << @config[:source]
		cmdarr << @config[:target]

		cmdarr.join(" ")
	end
end
