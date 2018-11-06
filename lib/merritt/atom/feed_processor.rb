module Merritt
  module Atom
    class FeedProcessor
      ARG_KEYS = %i[starting_point submitter profile collection_ark feeddatefile].freeze

      attr_reader :starting_point
      attr_reader :submitter
      attr_reader :profile
      attr_reader :collection_ark
      attr_reader :feeddatefile

      def initialize(starting_point:, submitter:, profile:, collection_ark:, feeddatefile:)
        @starting_point = starting_point
        @submitter = submitter
        @profile = profile
        @collection_ark = collection_ark
        @feeddatefile = feeddatefile
      end

      def process_feed!
        # do the thing
      end

      def process_page(page_url)
        return unless page_url
        page_processor = new PageProcessor(page_url: page_url, atom_processor: self)
        next_page = page_processor.process_page!
        process_page(next_page)
      end

    end
  end
end
