require 'optparse'
require 'octokit'
require 'faraday-http-cache'
require 'date'

module We
  module GitHubStats
    class Cli
      class ScriptOptions
        attr_accessor :access_token, :organization

        def initialize
          @format = 'console'
        end

        def define_options(parser)
          parser.banner = "Usage: github_stats [options]"
          parser.separator ""
          parser.separator "Specific options:"

          parser.on(
            "-o", "--organization wework",
            "GitHub organization to troll for stats"
          ) do |o|
            @organization = o
          end

          parser.on(
            "-t", "--token ABC123",
            "GitHub Access Token with read permissions for the organization"
          ) do |t|
            @access_token = t
          end

          parser.on(
            "-f", "--format",
            "How should it be output? Supported: console,csv"
          ) do |f|
            @format = f
          end

          parser.on_tail("-h", "--help", "Show this message") do
            puts parser
            exit
          end

          parser.on_tail("--version", "Show version") do
            puts VERSION
            exit
          end
        end

        attr_reader :parser, :options
      end

      def client(access_token)
        Octokit.auto_paginate = true
        stack = Faraday::RackBuilder.new do |builder|
          builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
          builder.use Octokit::Response::RaiseError
          builder.adapter Faraday.default_adapter
        end
        Octokit.middleware = stack

        Octokit::Client.new(access_token: access_token)
      end

      #
      # Return a structure describing the options.
      #
      def parse(args)
        @options = ScriptOptions.new
        @args = OptionParser.new do |parser|
          @options.define_options(parser)
          parser.parse!(args)
        end
        @options
      end

      def error(msg)
        puts msg
        return 0
      end

      def run
        return error("Missing --token option") if @options.access_token.nil?
        return error("Missing --organization option") if @options.organization.nil?

        organization = Organization.new(
          name: @options.organization,
          client: client(@options.access_token)
        )

        incomplete = []

        subtotals = organization.repos.map do |repo|
          begin
            repo_stats = {
              repo: repo.name,
              num_commits: repo.num_commits,
              num_lines_added: repo.num_lines_added,
              num_lines_removed: repo.num_lines_removed,
            }

          rescue Repository::InProgressError
            incomplete << repo.name
          end
          repo_stats
        end.compact

        if incomplete != []
          puts "ERROR! The following stats are not ready on the GitHub API:"
          incomplete.each { |repo_name| puts "\t- #{repo_name}" }
          puts "Please wait a few minutes and try again. In the meantime, the stats for other repos is..."
        end

        total_commits = subtotals.map { |r| r[:num_commits].to_i }.reduce(:+)
        total_lines_added = subtotals.map { |r| r[:num_lines_added].to_i }.reduce(:+)
        total_lines_removed = subtotals.map { |r| r[:num_lines_removed].to_i }.reduce(:+)

        puts "==== Repositories ===="
        subtotals.each { |s| puts "#{s[:repo]},#{s[:num_commits]},#{s[:num_lines_added]},#{s[:num_lines_removed]}" }

        puts "==== Total ===="
        puts "Total Commits: #{total_commits}"
        puts "Total Lines Added: #{total_lines_added}"
        puts "Total Lines Removed: #{total_lines_removed}"

        return 1
      end
    end
  end
end
