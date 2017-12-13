# eventful-promise
[![Build Status](https://travis-ci.org/danielkalen/eventful-promise.svg?branch=master)](https://travis-ci.org/danielkalen/eventful-promise)
[![Coverage](.config/badges/coverage.png?raw=true)](https://github.com/danielkalen/eventful-promise)
[![Code Climate](https://codeclimate.com/github/danielkalen/eventful-promise/badges/gpa.svg)](https://codeclimate.com/github/danielkalen/eventful-promise)
[![NPM](https://img.shields.io/npm/v/eventful-promise.svg)](https://npmjs.com/package/eventful-promise)

Create a Promise/EventEmitter hybrid that can emit events even after being resolved.

## Installation
```
npm install --save eventful-promise
```

## Usage
```javascript
var EventfulPromise = require('eventful-promise');
var myPromise = new EventfulPromise(function(resolve, reject){
    this.emit('some-event');
    
    setTimeout(()=> {
        this.emit('some-event');
        this.emit('another-event');
    }, 50);
    
    setTimeout(()=> {
        this.emit('about-to-resovle');
        resolve(123456);
    }, 100)
    
    setTimeout(()=> {
        this.emit('some-event');
        this.emit('another-event');
        this.emit('post-resolution');
    }, 200)
});
```

```javascript
myPromise
    .on('some-event', ()=> console.log('A'))
    .once('another-event', ()=> console.log('B'))
    .on('about-to-resovle', ()=> console.log('C'))
    .on('post-resolution', ()=> console.log('D'))
    .then((result)=> console.log('E', result))
    .catch((err)=> console.error(err))
```

#### Output of above code:
```
console -> A
console -> A
console -> B
console -> C
console -> E 123456
console -> A
console -> D
```


## API

#### Creation
There are three ways you can create an eventful promise:

Method       | Example
------------ | ----------
Callback     | `new EventfulPromise((resolve, reject)=> )`
Thenable     | `new EventfulPromise(Promise.resolve('value'))`
.resolve()   | `EventfulPromise.resolve('value').then(...)`


#### Emitting events
`EventfulPromise` instances inherit from [EventEmitter](https://nodejs.org/api/events.html) and thus have methods such as `.emit()` and `.on` and `.once`
```javascript
var promise = EventfulPromise.resolve();
promise.emit('someEvent');
promise.emit('anotherEvent');
promise.on('someEvent', ...);
promise.once('anotherEvent', ...);
```

The callback provided to the `EventfulPromise` constructor and the callback provided to the `eventfulPromise.then()` method will be invoked with the `EventfulPromise` instance as their context, thus allowing the instance to be referenced via the `this` keyword inside those callbacks.
```javascript
var promise = new EventfulPromise(function(resolve){
    this.emit('someEvent');
    resolve();
});

promise
    .then(function(){ this.emit('someEvent') });

EventfulPromise.resolve()
    .then(function(){ this.emit('someEvent') });
```









**License** (MIT)
Copyright 2017 danielkalen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.