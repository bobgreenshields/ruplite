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

