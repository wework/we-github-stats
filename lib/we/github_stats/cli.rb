require 'date'
require 'optparse'
require 'octokit'
require 'faraday-http-cache'
require 'terminal-table'

module We
  module GitHubStats
    class Cli
      OK = 1
      NOPE = 0

      class ScriptOptions
        attr_accessor :access_token, :organization, :format

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
            "-f", "--format console",
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
        return NOPE
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
              name: repo.name,
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
          puts "Warning: The following stats are not ready on the GitHub API:"
          incomplete.each { |repo_name| puts "\t- #{repo_name}" }
          puts "Please wait a few minutes and try again. In the meantime, the stats for other repos is..."
        end

        if @options.format == 'console'

          puts "==== Repositories ===="

          rows = subtotals.map { |r| [r[:name], r[:num_commits].to_i, r[:num_lines_added].to_i, r[:num_lines_removed].to_i] }

          puts Terminal::Table.new(
            headings: ['Name', 'Commits', 'Lines Added', 'Lines Removed'],
            rows: rows
          )

          total_commits = subtotals.map { |r| r[:num_commits].to_i }.reduce(:+)
          total_lines_added = subtotals.map { |r| r[:num_lines_added].to_i }.reduce(:+)
          total_lines_removed = subtotals.map { |r| r[:num_lines_removed].to_i }.reduce(:+)

          puts "==== Total ===="
          puts "Commits: #{total_commits}"
          puts "Lines Added: #{total_lines_added}"
          puts "Lines Removed: #{total_lines_removed}"
          return OK

        elsif @options.format == 'csv'
          puts 'Name, Commits, Lines Added, Lines Removed'
          subtotals.each { |s| puts "#{s[:name]},#{s[:num_commits]},#{s[:num_lines_added]},#{s[:num_lines_removed]}" }
          return OK
        end

        return error("Unknown output format selected")
      end
    end
  end
end
