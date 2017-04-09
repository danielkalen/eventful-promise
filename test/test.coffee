Promise = require 'bluebird'
# Promise.config longStackTraces:true
mocha = require 'mocha'
chai = require 'chai'
expect = chai.expect
EventfulPromise = require('../')


suite "eventful-promise", ()->
	test "constructor doesn't require arguments", ()->
		expect ()-> new EventfulPromise()
			.not.to.throw()

	test "instance should be an instance of EventEmitter", ()->
		promise = new EventfulPromise()
		expect(promise instanceof require('events')).to.be.true
		

	test "instance should be thenable when given a promise/function", ()->
		promise = new EventfulPromise(Promise.resolve('resolvedValue'))

		promise.then (result)->
			expect(result).to.equal('resolvedValue')
			
			Promise.resolve()
				.then ()-> promise
				.then (result)->
					expect(result).to.equal('resolvedValue')
	

	test "instance should be thenable when not given a promise/function", ()->
		promise = new EventfulPromise()

		promise.then (result)->
			expect(result).to.equal(undefined)
			
			Promise.resolve()
				.then(promise)
				.then (result)->
					expect(result).to.equal(undefined)


	test "instance should be catchable", ()->
		promise = new EventfulPromise(Promise.reject(new Error 'catchable'))

		promise
			.catch (err)->
				expect(err.message).to.equal('catchable')
				return 'i caught it'
			
			.then (result)-> expect(result).to.equal 'i caught it'


	test "instance can accept a funciton which will be immediatly invoked", ()->
		invoked = false
		promise = new EventfulPromise ()-> invoked = true; 'I was invoked'

		expect(invoked).to.be.true
		promise.then (result)->
			expect(result).to.equal 'I was invoked'


	test "if passed a function it will be invoked with the instance as its context", ()->
		context = null
		promise = new EventfulPromise ()-> context = @; return
		
		expect(context).to.equal(promise)



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

		return promise


