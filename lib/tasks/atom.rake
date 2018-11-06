require 'merritt/atom'

# TODO: make these non-constants
DELAY = 300
BATCH_SIZE = 10

namespace :atom do
  desc 'Generic Atom to Merritt processor'
  FeedProcessor = Merritt::Atom::FeedProcessor
  task :update, FeedProcessor::ARG_KEYS => :environment do |_, task_args|
    args = task_args.merge(delay: DELAY, batch_size: BATCH_SIZE)
    processor = FeedProcessor.new(args)
    processor.process_feed!
  end
end
