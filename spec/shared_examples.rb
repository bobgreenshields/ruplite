	shared_examples_for "all backups" do
		describe "#initialize" do
			context "with no name key" do
				it "should complain" do
					@config.delete :name
					expect { Ruplite.new(@config) }.to raise_error(ArgumentError)
				end
			end
			context "with no target key" do
				it "should complain" do
					@config.delete :target
					expect { Ruplite.new(@config) }.to raise_error(ArgumentError)
				end
			end
		end #initialize
		describe "#cmd" do
			include_context "cmd words"

			it "should have sudo as it's first word" do
				@cmd_word[0].should == "duplicity"
			end
			it "should have the target as it's last word" do
				@cmd_word[-1].should == @target
			end

			context "when run as sudo" do
				include_context "when run as sudo"
				include_context "cmd words"

				it "should have duplicity as it's first word" do
					@cmd_word[0].should == "sudo"
				end
				it "should have duplicity as it's second word" do
					@cmd_word[1].should == "duplicity"
				end
				it "should have the target as it's last word" do
					@cmd_word[-1].should == @target
				end

			end # when run as sudo

		end # cmd
	end # all backups

	shared_examples_for "a backup with a source" do
		describe "#initialize" do
			context "with no source key" do
				it "should complain" do
					@config.delete :source
					expect { Ruplite.new(@config) }.to raise_error(ArgumentError)
				end
			end
		end #initialize
		describe "#cmd" do
			include_context "cmd words"

			it "should have the source as it's next to last word" do
				@cmd_word[-2].should == @source
			end
		end # cmd
	end # with a source

	shared_examples_for "all backups with no action" do
		it_behaves_like "all backups"
		it_behaves_like "a backup with a source"

		describe "#cmd" do
			include_context "cmd words"

			it "should have --name as its second word" do
				@cmd_word[1].should == '--name'
			end
			it "should have the name as its third word" do
				@cmd_word[2].should == @name
			end
		end # cmd
	end # all backups with no action


	shared_examples_for "all backups with an action" do
		it_behaves_like "all backups"

		describe "#cmd" do
			include_context "cmd words"

			it "should have the action as its second word" do
				@cmd_word[1].should == @config[:action]
			end
		end # cmd
	end # with an action

	shared_examples_for "all backups with an action no arg" do
		it_behaves_like "all backups with an action"

		describe "#cmd" do
			include_context "cmd words"

			it "should have --name as its third word" do
				@cmd_word[2].should == '--name'
			end
			it "should have the name as its fourth word" do
				@cmd_word[3].should == @name
			end
		end # cmd
	end # an action no arg

	shared_examples_for "all backups with an action no arg with options" do
		describe "#cmd" do
			include_context "cmd words"
			include_context "option words"

			it "options should be words 5 onwards" do
				@option_word.each_index do |i|
					@cmd_word[i + 4].should == @option_word[i]
				end
			end
		end # cmd
	end # action no arg with options


	shared_examples_for "all backups with an action with a source" do
		it_behaves_like "all backups with an action no arg"
		it_behaves_like "a backup with a source"

	end # action with a source

	shared_examples_for "all non passphrase env items" do
		it "@env should have all non PASSPHRASE items in config" do
			@config || @config[:env].each do |k, v|
				unless k.upcase == "PASSPHRASE"
					Ruplite.new(@config).env.keys.should include k.upcase
					Ruplite.new(@config).env[k.upcase].should == v
				end
			end
		end
	end

	shared_examples_for "all env with a passphrase key" do
		it_behaves_like "all non passphrase env items"

		it "should have a key of PASSPHRASE" do
			Ruplite.new(@config).env.keys.should include "PASSPHRASE"
		end
		it "should have the password for the key of PASSPHRASE" do
			Ruplite.new(@config).env["PASSPHRASE"].should == @password
		end
	end

	shared_examples_for "all env with no passphrase key" do
		it_behaves_like "all non passphrase env items"

		it "@env should have same no. of items as config" do
			target = @config[:env].length
			Ruplite.new(@config).env.should have(target).things
		end
	end
