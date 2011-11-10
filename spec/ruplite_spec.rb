require 'spec_helper'

describe Ruplite do
	before(:each) do
		@log = Testlogger.new
		@source = "/mnt/data"
		@target = 'file:///mnt/media/backup'
		@action = 'incremental'
		@options = []
		@options << "--name data"
		@options << "--encrypt-key AA0E73D2"
		@options << "--sign-key AA0E73D2"
		@password = "xxxxx"
		@config = {}
		@config[:source] = @source
		@config[:target] = @target
		@config[:action] = @action
		@config[:options] = @options
		@config[:password] = @password
		@rup = Ruplite.new(@config, @log)
	end

	describe "#source" do
		subject { @rup.source }

		context "when /mnt/data" do
			it { should == " #{@source}" }
		end
	end

	it "should return source with a space prepended" do
		@rup.source.should == " #{@source}"
	end

	it "should return target with a space prepended" do
		@rup.target.should == " #{@target}"
	end

	context "with options" do
		it "options should prepend a space and join elements with spaces" do
			@rup.options.should == " #{@options.join(" ")}"
		end
	end

	context "without options" do
		it "options should return an empty string" do
			@config.delete :options
			@rup = Ruplite.new(@config, @log)
			@rup.options.should == ""
		end
	end

	context "with an action" do
		it "should return action with a space prepended" do
			@rup.action.should == " #{@action}"
		end
	end

	context "without an action" do
		it "action should return an empty string" do
			@config.delete :action
			@rup = Ruplite.new(@config, @log)
			@rup.action.should == ""
		end
	end

	it "command should retuen full command string" do
		cmd = "duplicity #{@action} #{@options.join(" ")} #{@source} #{@target}"
		@rup.command.should == cmd
	end


end
