class EventfulPromise extends require('events')
	constructor: (task)->
		super
		@init(task)
	
	init: (@task)->
		@taskPromise = Promise.resolve(if typeof @task is 'function' then @task.call(@) else @task)
		return @
	
	then: ()-> @taskPromise.then(arguments...)
	catch: ()-> @taskPromise.catch(arguments...)

module.exports = EventfulPromise