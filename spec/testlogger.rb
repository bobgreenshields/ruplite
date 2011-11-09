class Testlogger
	attr_reader :infolog, :debuglog, :errorlog 

	def initialize
		@infolog = []
		@debuglog = []
		@errorlog = []
	end

	def info(text)
		@infolog << text
	end

	def debug(text)
		@debuglog << text
	end

	def error(text)
		@errorlog << text
	end
	
end
