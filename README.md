#Structured logging library for dart

Allows to log not just String, but any objects. Also, you may even insert these logs 
into mongo database for more transparent search.

## Motivation

Using logging is quite necessary while developing larger applications. Sometimes you may want
to log some object and then handle these objects elsewhere. Additionally, if you are developing
a web application and want to filter logs for a specific user, some database with these logs
would come handy.

## What is the solution ?

Solution is simple - we introduce a *Logger* class, which allows you to log any objects,
appends timestamp and up-to-date metaData to each log. In addition, if you'd like to have 
the logs in a mongo database, we introduce you a *MongoLogger* class which in combination with
appropriate handler for logs serverside ( *ClientRequestHandler* ) or clientside ( *AjaxHandler* )
inserts all the logs into a collection in a mongo database. Therefore, it makes them much easier
to filter. 

It allows hierarchy of Loggers, in the means of logLevels. Every log is only logged if the
logLevel of corresponding Logger is smaller (at least as granular) as the level of given log.
If the logLevel of some Logger is null, the logLevel of parent Logger is considered.

All the logs are pushed into a common static stream, which can be listened to using either custom
handlers, or using the handlers provided.

As there already exists a package *logging*, we also provide some compatibility functions transforming
logs from one to to another.

Inspired by: http://www.dartdocs.org/documentation/logging/0.9.2/index.html#logging
