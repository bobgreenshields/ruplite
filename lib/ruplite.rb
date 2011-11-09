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
	def initialize (config, logger = nil)
		@logger = logger || NullLogger.new
		@config = config
	end

	def source
		" #{@config[:source]}"
	end

	def target
		" #{@config[:target]}"
	end

	def options
		if @config.has_key? :options
			" #{@config[:options].join(" ")}"
		else
			""
		end
	end

	def action
		if @config.has_key? :action
			" #{@config[:action]}"
		else
			""
		end
	end

	def command
		"duplicity#{action}#{options}#{source}#{target}"
	end
end
