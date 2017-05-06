class EventfulPromise extends require('events')
	constructor: (task)->
		_ = @
		super
		switch
			when typeof task is 'function'
				@task = new EventfulPromise.Promise (resolve, reject)-> task.call(_, resolve, reject)

			when typeof task is 'object' and task and typeof task.then is 'function'
				@task = task
			
			else throw new Error 'EventfulPromise constructor must be invoked either with a Promise object or a callback argument'

	
	then: (cbResolve, cbReject)->
		@task.then(
			cbResolve.bind(@)
			cbReject.bind(@) if cbReject
		)
	
	catch: ()->
		@task.catch(arguments...)

	@Promise = Promise
	@resolve = (value)-> new EventfulPromise(EventfulPromise.Promise.resolve(value))

module.exports = EventfulPromise