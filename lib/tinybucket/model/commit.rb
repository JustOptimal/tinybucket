module Tinybucket
  module Model
    class Commit < Base
      include Tinybucket::Model::Concerns::RepositoryKeys
      include Tinybucket::Model::Concerns::Reloadable
      include Tinybucket::Constants

      acceptable_attributes \
        :hash, :links, :repository, :author, :parents, :date,
        :message, :participants, :uuid

      def comments(options = {})
        enumerator(
          comments_api,
          :list,
          options
        ) { |m| block_given? ? yield(m) : m }
      end

      def comment(comment_id, options = {})
        comments_api.find(comment_id, options)
      end

      private

      def comments_api
        raise ArgumentError, MISSING_REPOSITORY_KEY unless repo_keys?

        api = create_api('Comments', repo_keys)
        api.commented_to = self
        api
      end

      def commit_api
        create_api('Commits', repo_keys)
      end

      def load_model
        commit_api.find(hash)
      end
    end
  end
end
