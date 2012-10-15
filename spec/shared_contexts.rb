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

shared_context "with a passphrase key set" do
	before :each do
		@config[:passphrase] = @password
	end
end

shared_context "when run as sudo" do
	before :each do
		@config[:run_as_sudo] = "true"
	end
end
