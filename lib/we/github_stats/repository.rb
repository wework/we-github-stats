module We
  module GitHubStats
    class Repository
      class InProgressError < StandardError; end

      def initialize(client, name)
        @client = client
        @name = name
      end

      attr_reader :name

      def num_commits
        fetch_commit_activity && fetch_commit_activity.map(&:total).inject(:+)
      end

      def num_lines_added
        fetch_code_frequency && fetch_code_frequency.map { |week| week[1] }.inject(:+)
      end

      def num_lines_removed
        fetch_code_frequency && fetch_code_frequency.map { |week| week[2] }.inject(:+)
      end

      private

      attr_reader :client

      def fetch_commit_activity
        @fetch_commit_activity ||= begin
          client.commit_activity_stats(name).tap do
            raise InProgressError if stats_building?
            raise "PANIC!" if error?
          end
        end
      end

      def fetch_code_frequency
        @fetch_code_frequency ||= begin
          data = client.code_frequency_stats(name)

          raise InProgressError if stats_building?
          raise "PANIC!" if error?

          return nil if data.nil?

          current_date = DateTime.now

          data.reject do |week|
            days_ago = (current_date - Time.at(week[0]).to_datetime).to_i
            days_ago > 365
          end
        end
      end

      def stats_building?
        client.last_response.status == 202
      end

      def error?
        client.last_response.status >= 400
      end
    end
  end
end
