require 'eventless/version'
require 'eventless/fiber'
require 'eventless/socket'
require 'eventless/loop'
require 'eventless/resolver'
require 'eventless/addrinfo'
require 'eventless/select'
require 'eventless/timeout'
require 'eventless/event'
require 'eventless/threadpool'
require 'eventless/core_ext/string'
require 'eventless/util'

module Kernel
  alias_method :sleep_block, :sleep

  def sleep(duration)
    Eventless.loop.sleep(duration)
  end
end

module Eventless
  def self.spawn(&block)
    _loop = Eventless.loop
    f = Fiber.new(_loop.fiber, &block)
    _loop.schedule(f)

    f
  end

  def self.loop
    Loop.default
  end

  def self.thread_patched?
    false
  end

  def self.threadpool
    Loop.default.threadpool
  end
end
