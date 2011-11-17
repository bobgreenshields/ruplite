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

	describe "#cmd" do
		it "should produce a good cmd string from inputs" do
			@config[:action] = @action
			@config[:options] = @options
			@rup = Ruplite.new(@name, @config, @log)
			@rup.cmd.should == "duplicity #{@action} --name #{@name} #{@options.join(" ")} #{@source} #{@target}"
		end

	end

	shared_examples_for "env variables" do
		it "should capitalise each key and have each value in env key" do
			@env.each do |k, v|
				upcase_key = k.upcase
				@rup.env[upcase_key].should == v unless upcase_key == "PASSWORD"
			end
		end
	end

	describe "#define_env_variables" do
		context "with a password key set" do
			before(:each) do
				@config[:password] = @password
			end
			context "with no env variable password" do
				before(:each) do
					@config[:env] = @env
					@rup = Ruplite.new(@name, @config, @log)
				end

				it_should_behave_like "env variables"

				it "should have the password keys value" do
					@rup.env["PASSWORD"].should == @password
				end
			end

			context "with an env variable password set" do
				before(:each) do
					@env["PASSWORD"] = @env_pword
					@config[:env] = @env
					@rup = Ruplite.new(@name, @config, @log)
				end

				it_should_behave_like "env variables"

				it "should have the password keys value" do
					@rup.env["PASSWORD"].should == @password
				end
			end
		end

		context "without password key set" do
			context "with no env variable password" do
				before(:each) do
					@config[:env] = @env
					@rup = Ruplite.new(@name, @config, @log)
				end

				it_should_behave_like "env variables"

				it "should not have a password key" do
					@rup.env.should_not have_key "PASSWORD"
				end
			end

			context "with an env variable password set" do
				before(:each) do
					@env["PASSWORD"] = @env_pword
					@config[:env] = @env
					@rup = Ruplite.new(@name, @config, @log)
				end

				it_should_behave_like "env variables"

				it "should have the env variables password value" do
					@rup.env["PASSWORD"].should == @env_pword
				end
			end
		end
	end

	describe "initialization checks" do
		%w(source target).each do |inp|
			it "should raise an error if #{inp} is not defined" do
				@config.delete inp.to_sym
				lambda {Ruplite.new(@name, @config, @log)}.
					should raise_error(ArgumentError)
			end
		end

		it "should raise an error if a --name option is passed" do
			@options << "--name new-backup"
			@config[:options] = @options
			lambda {Ruplite.new(@name, @config, @log)}.
				should raise_error(ArgumentError)
		end
	end

	describe "setting environment variables" do
		before(:each) do
			@config[:env] = @env
			@config[:password] = @password
			@rup = Ruplite.new(@name, @config, @log)
			@rup.stub!(:set_system_env_var).as_null_object
		end
		describe "#set_env_vars" do
			it "should call set_system_env_var method for each env value" do
				@rup.should_receive(:set_system_env_var).
					exactly(@env.length + 1).times
				@rup.set_env_vars
			end
		end

		describe "#reset_env_vars" do
			context "when no env vars have been set" do
				it "should not call set_system_env_var method" do
					@rup.should_not_receive(:set_system_env_var)
					@rup.reset_env_vars
				end
			end

			context "when env vars have been set" do
				before { @rup.set_env_vars }

				it "should call set_system_env_var method for each env value" do
					@rup.should_receive(:set_system_env_var).
						exactly(@env.length + 1).times
					@rup.reset_env_vars
				end
			end
		end
	end

end
