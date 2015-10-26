//import ch.qos.logback.classic.encoder.PatternLayoutEncoder
//import ch.qos.logback.core.ConsoleAppender
// 
//import static ch.qos.logback.classic.Level.DEBUG

appender("stdout", ConsoleAppender) {
	encoder(PatternLayoutEncoder) {
	  pattern = "%d{yyyy-MM-dd HH:mm:ss} Groovy %-5p %c{1}:%L - %m%n"
	}
}
  
root(DEBUG, ["stdout"])