module Db

  class << self
    attr_accessor :connection

    def connect(*args)
      @connection = Connection.new
      @connection.establish!(*args)

      Moped.logger = App.logger
    end

  end

  class Connection
    attr_accessor :session

    def establish!(params, db)
      @session = Moped::Session.new(params)
      @session.use db
    end

    def method_missing(method, *args, &block)
      @session.send(method, *args, &block)
    end
  end

end
