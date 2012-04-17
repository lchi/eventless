require 'socket'

module Eventless
  RealAddrinfo = ::Addrinfo

  class Addrinfo
    def initialize(sockaddr, *rest)
      if sockaddr
        @addrinfo = RealAddrinfo.new(sockaddr, *rest)
      end
    end

    def self._wrap(real_addrinfo)
      addrinfo = new(false)
      addrinfo.send(:addrinfo=, real_addrinfo)

      addrinfo
    end

    class << self
      # wrapped blocking class methods that all need to
      # have their return values cast to Eventless::Addrinfo
      [:ip, :tcp, :udp].each do |sym|
        define_method(sym) do |*args|
          queue = Queue.new
          watcher = Eventless.loop.async
          Eventless.loop.attach(watcher)

          Eventless.threadpool.schedule do
            res = _wrap(RealAddrinfo.send(sym, *args))
            queue << res
            watcher.signal
          end
          Eventless.loop.transfer

          queue.shift
        end
      end

      # wrapped non-blocking class methods
      [:unix].each do |sym|
        define_method(sym) do |*args|
          RealAddrinfo.send(sym, *args)
        end
      end
    end

    # wrapped blocking instance methods
    [:ip_unpack, :inspect_sockaddr].each do |sym|
      define_method(sym) do |*args|
        RealAddrinfo.send(sym, *args)
      end
    end

    # wrapped blocking instance methods that
    # call ruby methods that have been patched
    [:connect, :connect_from, :connect_to, :listen].each do |sym|
      define_method(sym) do |*args|
        @addrinfo.send(sym, *args)
      end
    end

    # wrapped non-blocking instance methods
    [:afamily, :socktype, :protocol, :to_sockaddr, :ip_address, :ip_port,
     :bind, :canonname, :ip?, :ipv4?, :ipv4_loopback?, :ipv4_multicast?,
     :ipv4_private?, :ipv6?, :ipv6_linklocal?, :ipv6_loopback?,
     :ipv6_mc_global?, :ipv6_mc_linklocal?, :ipv6_mc_nodelocal?,
     :ipv6_mc_orglocal?, :ipv6_mc_sitelocal?, :ipv6_multicast?,
     :ipv6_sitelocal?, :ipv6_to_ipv4, :ipv6_unspecified?, :ipv6_v4compat?,
     :ipv6_v4mapped?, :unix?, :to_s, :to_sockaddr, :pfamily, :unix_path].each do |sym|
      define_method(sym) do |*args|
        @addrinfo.send(sym, *args)
      end
    end

    def self.foreach(*args, &block)
      RealAddrinfo.foreach(*args, &block)
    end

    def self.getaddrinfo(*args)
      queue = Queue.new
      watcher = Eventless.loop.async
      Eventless.loop.attach(watcher)

      Eventless.threadpool.schedule do
        addrs = RealAddrinfo.getaddrinfo(*args).map { |ai| _wrap(ai) }
        queue << addrs
        watcher.signal
      end
      Eventless.loop.transfer

      queue.shift
    end

    def family_addrinfo(*args)
      queue = Queue.new
      watcher = Eventless.loop.async
      Eventless.loop.attach(watcher)

      Eventless.threadpool.schedule do
        addrs = RealAddrinfo.family_addrinfo(*args).map { |ai| _wrap(ai) }
        queue << addrs
        watcher.signal
      end
      Eventless.loop.transfer

      queue.shift
    end

    def getnameinfo(*args)
      queue = Queue.new
      watcher = Eventless.loop.async
      Eventless.loop.attach(watcher)

      Eventless.threadpool.schedule do
        nameinfo = @addrinfo.getnameinfo(*args)
        queue << nameinfo
        watcher.signal
      end
      Eventless.loop.transfer

      queue.shift
    end

    def inspect
      "#<Eventless::Addrinfo:#{@addrinfo.inspect.split("Addrinfo:").last.chop}>"
    end

    private

    def addrinfo=(addrinfo)
      @addrinfo = addrinfo
    end
  end
end

Object.send(:remove_const, :Addrinfo)
Addrinfo = Eventless::Addrinfo
