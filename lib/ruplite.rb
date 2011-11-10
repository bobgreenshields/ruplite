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
		@name = name
		@config = config
		@logger = logger || NullLogger.new
	end

	def cmd
		cmdarr = ['duplicity']

		cmdarr.join(" ")
	end
end
