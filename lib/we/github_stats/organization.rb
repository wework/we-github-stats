module We
  module GitHubStats
    class Organization
      def initialize(client:, name:)
        @client = client
        @name = name
      end

      def repos
        @repos ||= begin
          client.org_repos(name).compact.reject(&:fork).map do |repo|
            Repository.new(client, repo.full_name)
          end
        end
      end

      private

      attr_reader :client, :name
    end
  end
end
