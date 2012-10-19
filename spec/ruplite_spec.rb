require 'spec_helper'

describe Ruplite do
	before(:each) do
		@log = Testlogger.new
		@name = 'data'
		@source = "/mnt/data"
		@target = 'file:///mnt/media/backup'
		@action = 'incremental'
		@action_arg = '3D'
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
		@config[:action_arg] = @action_arg
		@config[:options] = @options
		@config[:env] = @env
	end

	describe "#initialize_env" do
		context "with no config env" do
			before :each do
				@config.delete :env
			end
			it "@env should be a hash" do
				Ruplite.new(@config).env.should be_a_kind_of Hash
			end

			context "with no passphrase key set" do
				it "should have no items" do
					Ruplite.new(@config).env.should have(0).things
				end
			end
			context "with a passphrase key set" do
				include_context "with a passphrase key set"

				it_behaves_like "all env with a passphrase key"

				it "should have 1 item" do
					Ruplite.new(@config).env.should have(1).things
				end
			end
		end # no config env

		context "with a config env" do
			it "@env should be a hash" do
				Ruplite.new(@config).env.should be_a_kind_of Hash
			end
			context "with no passphrase key set" do
				it_behaves_like "all env with no passphrase key"
			end
			context "with a passphrase key set" do
				include_context "with a passphrase key set"

				context "with no passphrase in the env" do
					it_behaves_like "all env with a passphrase key"

					it "@env should have 1 extra item than config" do
						target = @config[:env].length + 1
						Ruplite.new(@config).env.should have(target).things
					end

				end

				context "with a passphrase in the env" do
					before :each do
						@env["PASSPHRASE"] = @env_pword
					end

				it "@env should have same no. of items as config" do
					target = @config[:env].length
					Ruplite.new(@config).env.should have(target).things
				end

					it_behaves_like "all env with a passphrase key"
				end
#				it "should have 1 item" do
#					Ruplite.new(@config).env.should have(1).things
#				end
			end
		end # with a config env
	end # initialize_env

	describe "# check_boolean" do
		%w(true True TRUE).each do |true_str|
			context "with #{true_str} string" do
				it "should return true" do
					Ruplite.new(@config).check_boolean(true_str).should == true
				end
			end
		end
		context "with symbol :true" do
			it "should return true" do
				Ruplite.new(@config).check_boolean(:true).should == true
			end
		end
		context "with non true string" do
			it "should return false" do
				Ruplite.new(@config).check_boolean("blurb").should == false
			end
		end
		context "with something that does not coerce to string" do
			it "should return false" do
				Ruplite.new(@config).check_boolean(nil).should == false
			end
		end
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

				context "when run as sudo" do
					include_context "when run as sudo"
					include_context "cmd words"

					it "should have 6 words" do
						@cmd_word.length.should == 6
					end
				end # run as sudo

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

				context "when run as sudo" do
					include_context "when run as sudo"
					include_context "cmd words"
					include_context "option words"

					it "options should be words 5 onwards" do
						@option_word.each_index do |i|
							@cmd_word[i + 4].should == @option_word[i]
						end
					end

					it "should have 6 plus no of option words" do
						@cmd_word.length.should == 6 + @option_word.length
					end
				end # when run as sudo

			end # cmd
		end # and with options
	end # with no action

	context "with action no source" do
		before :each do
			@config[:action] = "list-current-files"
		end

		it_behaves_like "all backups with an action no arg"

		context "and no options" do
			before :each do
				@config.delete :options
			end

			describe "#cmd" do
				include_context "cmd words"

				it "should have 5 words" do
					@cmd_word.length.should == 5
				end
			end # cmd
		end # and no options

		context "and with options" do

		it_behaves_like "all backups with an action no arg with options"

			describe "#cmd" do
				include_context "cmd words"
				include_context "option words"

				it "should have 5 plus no of option words" do
					@cmd_word.length.should == 5 + @option_word.length
				end
			end # cmd
		end # and with options
	end # with action no source

	context "with an action with source" do
		before :each do
			@config[:action] = "verify"
		end

		it_behaves_like "all backups with an action with a source"

		context "and no options" do
			before :each do
				@config.delete :options
			end

			describe "#cmd" do
				include_context "cmd words"

				it "should have 6 words" do
					@cmd_word.length.should == 6
				end
			end # cmd
		end # and no options

		context "and with options" do

		it_behaves_like "all backups with an action no arg with options"

			describe "#cmd" do
				include_context "cmd words"
				include_context "option words"

				it "should have 6 plus no of option words" do
					@cmd_word.length.should == 6 + @option_word.length
				end
			end # cmd
		end # and with options
	end # action with source

	context "with an action with an argument" do
		before :each do
			@config[:action] = "remove-older-than"
		end

		it_behaves_like "all backups with an action"

		describe "#initialize" do
			context "with no action_arg key" do
				it "should complain" do
					@config.delete :action_arg
					expect { Ruplite.new(@config) }.to raise_error(ArgumentError)
				end
			end
		end #initialize

		describe "#cmd" do
			include_context "cmd words"

			it "should have the action_arg as its third word" do
				@cmd_word[2].should == @config[:action_arg]
			end
			it "should have --name as its fourth word" do
				@cmd_word[3].should == '--name'
			end
			it "should have the name as its fifth word" do
				@cmd_word[4].should == @name
			end
		end # cmd

		context "and no options" do
			before :each do
				@config.delete :options
			end

			describe "#cmd" do
				include_context "cmd words"

				it "should have 6 words" do
					@cmd_word.length.should == 6
				end
			end # cmd
		end # and no options

		context "and with options" do
			describe "#cmd" do
				include_context "cmd words"
				include_context "option words"

				it "options should be words 6 onwards" do
					@option_word.each_index do |i|
						@cmd_word[i + 5].should == @option_word[i]
					end
				end
				it "should have 6 plus no of option words" do
					@cmd_word.length.should == 6 + @option_word.length
				end
			end # cmd
		end # and with options
	end # action with an argument
end
