require 'thread'

silence_warnings do
  require 'cool.io'
end

# for the most part ported fro gevent/threadpool.py
module Eventless
  class Loop
    def threadpool
      @threadpool ||= ThreadPool.new
    end
  end

  class ThreadPool
    # XXX: gevent uses maxsize of 10
    def initialize(threadpool_size=10)
      @queue = Queue.new
      @workers = []

      queue = @queue
      threadpool_size.times do
      @workers << Thread.new do
          loop do
            task = queue.pop
            task.call
          end
        end
      end
    end

    def schedule(&block)
      @queue.push(block)
    end
  end
end
