module Daemonizer
  # @private
  def self.__p(*path) File.join(File.dirname(File.expand_path(__FILE__)), *path) end

  autoload :Config,         __p('config')
  autoload :Dsl,            __p('dsl')
  autoload :Errors,         __p('errors')
  autoload :CLI,            __p('cli')
  autoload :Daemonize,      __p('daemonize')
  autoload :Engine,         __p('engine')
  autoload :Worker,         __p('worker')
  autoload :WorkerPool,     __p('worker_pool')
  autoload :ProcessManager, __p('process_manager')
  autoload :Handler,        __p('handler')
  autoload :FakeHandler,    __p('handler')

  include Errors
end
