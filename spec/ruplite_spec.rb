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
		@rup = Ruplite.new(@name, @config, @log)
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

	context "no actions and no options" do
		it_should_behave_like "all inputs"
	end



end
