require 'spec_helper'

describe Ruplite do
	before(:each) do
		@log = Testlogger.new
		@name = 'data'
		@source = "/mnt/data"
		@target = 'file:///mnt/media/backup'
		@action = 'incremental'
		@options = []
		@options << "--encrypt-key AA0E73D2"
		@options << "--sign-key AA0E73D2"
		@password = "xxxxx"
		@env_pword = "env pword"
		@env = {"aws_password" => "awsaws", "aws_key" => "a36b7f4"}
		@config = {}
		@config[:source] = @source
		@config[:target] = @target
		@config[:name] = @name
		@config[:action] = @action
		@config[:options] = @options
	end

	context "with no action" do
		before :each do
			@config.delete :action
		end
		
		context "and no options" do
			before :each do
				@config.delete :options
			end

			it_behaves_like "all backups with no action"

			describe "#cmd" do
				include_context "cmd words"

				it "should have 5 words" do
					@cmd_word.length.should == 5
				end
			end # cmd
		end # and no options

		context "and with options" do

			it_behaves_like "all backups with no action"

			describe "#cmd" do
				include_context "cmd words"
				include_context "option words"

				it "options should be words 4 onwards" do
					@option_word.each_index do |i|
						@cmd_word[i + 3].should == @option_word[i]
					end
				end

				it "should have 5 plus no of option words" do
					@cmd_word.length.should == 5 + @option_word.length
				end
			end # cmd
		end # and with options

	end # with no action
end
