Promise = require 'bluebird'
# Promise.config longStackTraces:true
mocha = require 'mocha'
chai = require 'chai'
expect = chai.expect
EventfulPromise = require('../')


suite "eventful-promise", ()->
	test "constructor cannot be invoked without an argument", ()->
		expect ()-> new EventfulPromise()
			.to.throw()
		
		expect ()-> new EventfulPromise({})
			.to.throw()
	
	
	test "constructor can be invoked with a callback that will get resolve/reject arguments", ()->
		invokeCount = 0
		promise = new EventfulPromise (resolve, reject)->
			invokeCount++
			expect(typeof resolve).to.equal 'function'
			expect(typeof reject).to.equal 'function'
			
			setTimeout ()->
				resolve('works')
			, 10
		
		expect(invokeCount).to.equal 1
		
		promise.then (result)->
			expect(result).to.equal 'works'

	
	test "constructor can be invoked with a promise that will be followed", ()->
		originalPromise = Promise.resolve('works').delay(8)		
		promise = new EventfulPromise originalPromise
		
		promise.then (result)->
			expect(result).to.equal 'works'


	test "A resolved promise can be created via .resolve()", ()->
		EventfulPromise.resolve('A')
			.then (result)-> expect(result).to.equal 'A'
			.then ()-> EventfulPromise.resolve('B')
			.then (result)-> expect(result).to.equal 'B'
			.then ()-> Promise.resolve('C')
			.then (result)-> expect(result).to.equal 'C'



	test "instance should be an instance of EventEmitter", ()->
		expect((new EventfulPromise ()->) instanceof require('events')).to.be.true
		expect((new EventfulPromise Promise.resolve()) instanceof require('events')).to.be.true
		expect((EventfulPromise.resolve()) instanceof require('events')).to.be.true
		

	test "instance should be thenable when given a promise/function", ()->
		promise = new EventfulPromise(Promise.resolve('resolvedValue'))

		promise.then (result)->
			expect(result).to.equal('resolvedValue')
			
			Promise.resolve()
				.then ()-> promise
				.then (result)->
					expect(result).to.equal('resolvedValue')


	test "instance should be catchable", ()->
		promise = new EventfulPromise(Promise.reject(new Error 'catchable'))

		promise
			.catch (err)->
				expect(err.message).to.equal('catchable')
				return 'i caught it'
			.then (result)->
				expect(result).to.equal 'i caught it'
			

	test "instance can accept a function which will be immediatly invoked", ()->
		invoked = false
		promise = new EventfulPromise (resolve)-> invoked = true; resolve('I was invoked')

		expect(invoked).to.be.true
		promise.then (result)->
			expect(result).to.equal 'I was invoked'


	test "if passed a function it will be invoked with the instance as its context", ()->
		context = null
		promise = new EventfulPromise (resolve)-> context = @; resolve()
		
		expect(context).to.equal(promise)
		
		context = null
		promise = EventfulPromise.resolve()
		promise
			.then ()-> context = @
			.then ()->
				expect(context).to.equal(promise)
				
				context = null
				promise = new EventfulPromise Promise.resolve()
				promise
					.then ()-> context = @
					.then ()-> expect(context).to.equal(promise)



	test "instance can emit events and will continue to emit after the promise was resolved", ()->
		invokeCount = eventA:0, eventB:0, eventC:0
		realPromise = new Promise ()->
		promise = new EventfulPromise realPromise
		
		promise
			.on 'eventA', ()-> invokeCount.eventA++
			.once 'eventB', ()-> invokeCount.eventB++
			.on 'eventC', ()-> invokeCount.eventC++
			.then (result)->
				expect(invokeCount.eventA).to.equal(3)
				expect(invokeCount.eventB).to.equal(1)
				expect(invokeCount.eventC).to.equal(2)
				expect(result).to.equal('someValue')
				
				promise.emit('eventA')
				expect(invokeCount.eventA).to.equal(4)

		promise.emit('eventA')
		promise.emit('eventB')
		promise.emit('eventC')
		expect(invokeCount.eventA).to.equal(1)
		expect(invokeCount.eventB).to.equal(1)
		expect(invokeCount.eventC).to.equal(1)

		promise.emit('eventA')
		promise.emit('eventB')
		promise.emit('eventC')
		expect(invokeCount.eventA).to.equal(2)
		expect(invokeCount.eventB).to.equal(1)
		expect(invokeCount.eventC).to.equal(2)

		promise.removeAllListeners('eventC')
		promise.emit('eventA')
		promise.emit('eventB')
		promise.emit('eventC')
		expect(invokeCount.eventA).to.equal(3)
		expect(invokeCount.eventB).to.equal(1)
		expect(invokeCount.eventC).to.equal(2)
		setImmediate ()-> realPromise._fulfill('someValue')

		promise.then ()->
			expect(invokeCount.eventA).to.equal(4)
			expect(invokeCount.eventB).to.equal(1)
			expect(invokeCount.eventC).to.equal(2)
			
			promise.emit('eventA')
			promise.emit('eventB')
			promise.emit('eventC')
			expect(invokeCount.eventA).to.equal(5)
			expect(invokeCount.eventB).to.equal(1)
			expect(invokeCount.eventC).to.equal(2)

		return promise


	test "by default EventfulPromise will use the Promise object available on the global scope, but can be set by redefining EventfulPromise.Promise", ()->
		promise = new EventfulPromise ()->
		expect(promise.task.constructor).not.to.equal require('bluebird')
		expect(promise.task.constructor).to.equal global.Promise
		expect(EventfulPromise.Promise).to.equal global.Promise
		expect(EventfulPromise.resolve().task.constructor).to.equal global.Promise
		
		EventfulPromise.Promise = Promise
		promise2 = new EventfulPromise ()->
		expect(promise2.task.constructor).to.equal require('bluebird')
		expect(promise2.task.constructor).not.to.equal global.Promise
		expect(EventfulPromise.Promise).not.to.equal global.Promise
		expect(EventfulPromise.resolve().task.constructor).not.to.equal global.Promise

















