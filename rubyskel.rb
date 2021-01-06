#!/usr/bin/env ruby

require 'tty-option' # Usage: https://github.com/piotrmurach/tty-option
require 'tty-logger' # Usage: https://github.com/piotrmurach/tty-logger

# Create a command that mixes all parameters usage:

class Command
  include TTY::Option

  usage do
    program "dock"

    command "run"

    desc "Run a command in a new container"

    example "Set working directory (-w)",
            "  $ dock run -w /path/to/dir/ ubuntu pwd"

    example <<~EOS
    Mount volume
      $ dock run -v `pwd`:`pwd` -w `pwd` ubuntu pwd
    EOS
  end

  argument :image do
    required
    desc "The name of the image to use"
  end

  argument :command do
    optional
    desc "The command to run inside the image"
  end

  keyword :restart do
    default "no"
    permit %w[no on-failure always unless-stopped]
    desc "Restart policy to apply when a container exits"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

  flag :detach do
    short "-d"
    long "--detach"
    desc "Run container in background and print container ID"
  end

  option :name do
    required
    long "--name string"
    desc "Assign a name to the container"
  end

  option :port do
    arity one_or_more
    short "-p"
    long "--publish list"
    convert :list
    desc "Publish a container's port(s) to the host"
  end

  def run
    if params[:help]
      print help
      exit
    else
      pp params.to_h
    end
  end
end

# Create a command instance:
cmd = Command.new
# Parse from argv
cmd.parse
# Run the command to see the values:
cmd.run
# =>
# {:help=>false,
#  :detach=>true,
#  :port=>["5000:3000", "5001:8080"],
#  :name=>"web",
#  :restart=>"always",
#  :image=>"ubuntu:16.4",
#  :command=>"bash"}

# The cmd object also has a direct access to all the parameters via the params:
#   cmd.params[:name]     # => "web"
#   cmd.params["command"] # => "bash"

# tty-logger usage:
# Create a logger
logger = TTY::Logger.new
# And log information using any of the logger built-in types:
# There are many logger types to choose from:
#   debug - logs message at :debug level
#   info - logs message at :info level
#   success - logs message at :info level
#   wait - logs message at :info level
#   warn - logs message at :warn level
#   error - logs message at :error level
#   fatal - logs message at :fatal level
# To log a message, simply choose one of the above types and pass in the actual message. 
# For example, to log successfully deployment at info level do:
#   logger.success "Deployed successfully"
#   ✔ success Deployed successfully
