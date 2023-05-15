class Logger::CustomFormatter < Logger::Formatter
  cattr_accessor(:datetime_format) { '%Y/%m/%d %H:%M:%S' }

  def call(severity, timestamp, _progname, msg)
    "[#{timestamp.strftime(datetime_format)}.#{format('%06d', timestamp.usec.to_s)}] (pid=#{$PROCESS_ID}) #{severity} -- : #{String == msg.class ? msg : msg.inspect}\n"
  end
end
