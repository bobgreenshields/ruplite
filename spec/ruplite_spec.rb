require 'spec_helper'

describe Ruplite do
	before(:each) do
		@log = Testlogger.new
		@name = 'data'
		@source = "/mnt/data"
		@target = 'file:///mnt/media/backup'
		@action = 'incremental'
		@options = []
#		@options << "--name data"
		@options << "--encrypt-key AA0E73D2"
		@options << "--sign-key AA0E73D2"
		@password = "xxxxx"
		@config = {}
		@config[:source] = @source
		@config[:target] = @target
#		@config[:action] = @action
#		@config[:options] = @options
		@config[:password] = @password
#		@rup = Ruplite.new(@name, @config, @log)
	end

	shared_examples_for "all inputs" do
		subject { @rup }

		describe "#name" do
			its(:name) { should == @name }
		end

		describe "#cmd" do
			before(:each) do
				@words = @rup.cmd.split(" ")
			end

			it "should have duplicity as its first word" do
				@words[0].should == "duplicity"
			end

			it "should have the target as its last word" do
				@words[-1].should == @target
			end

			it "should have the source as its next to last word" do
				@words[-2].should == @source
			end
		end
	end

	shared_examples_for "without an action" do
		describe "#cmd" do
			before(:each) do
				@words = @rup.cmd.split(" ")
			end

			it "should have --name as its second word" do
				@words[1].should == "--name"
			end

			it "should have the name as it third word" do
				@words[2].should == @name
			end
		end
	end

	shared_examples_for "with an action" do
		describe "#cmd" do
			before(:each) do
				@words = @rup.cmd.split(" ")
			end

			it "should have the action as its second word" do
				@words[1].should == @action
			end

			it "should have --name as its third word" do
				@words[2].should == "--name"
			end

			it "should have the name as it fourth word" do
				@words[3].should == @name
			end
		end
	end

	shared_examples_for "with options" do
		it "should have all the words from options before the last 2 words" do
			length = @options.join(" ").split(" ").length
			start = -2 - length
			@words[start,length].join(" ").should == @options.join(" ")
		end
	end

	context "no actions and no options" do
		before(:each) do
			@rup = Ruplite.new(@name, @config, @log)
		end

		it_should_behave_like "all inputs"
		it_should_behave_like "without an action"

		before(:each) do
			@words = @rup.cmd.split(" ")
		end

		it "should be 5 words long" do
			@words.length.should == 5
		end

	end

	context "with an action but no options" do
		before(:each) do
			@config[:action] = @action
			@rup = Ruplite.new(@name, @config, @log)
		end

		it_should_behave_like "all inputs"
		it_should_behave_like "with an action"

		before(:each) do
			@words = @rup.cmd.split(" ")
		end

		it "should be 6 words long" do
			@words.length.should == 6
		end
	end

	context "no actions but with options" do
		before(:each) do
			@config[:options] = @options
			@rup = Ruplite.new(@name, @config, @log)
		end

		it_should_behave_like "all inputs"
		it_should_behave_like "without an action"
		it_should_behave_like "with options"

		before(:each) do
			@words = @rup.cmd.split(" ")
		end

		it "should be 9 words long" do
			@words.length.should == 9
		end
	end


end
