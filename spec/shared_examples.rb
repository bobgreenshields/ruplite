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

			it "should have duplicity as it's first word" do
				@cmd_word[0].should == "duplicity"
			end
			it "should have the target as it's last word" do
				@cmd_word[-1].should == @target
			end
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
