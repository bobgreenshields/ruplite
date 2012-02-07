shared_context "cmd words" do
	before :each do
		@cmd_word = Ruplite.new(@config).cmd.split(" ")
	end
end

shared_context "option words" do
	before :each do
		@option_word = @options.join(" ").split(" ")
	end
end
