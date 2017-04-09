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
var myPromise = new EventEmitter(new Promise(function(resolve, reject){
    this.emit('some-event');
    
    setTimeout(function(){
        this.emit('some-event');
        this.emit('another-event');
    }, 50);
    
    setTimeout(function(){
        this.emit('about-to-resovle');
        resolve(123456);
    }, 100)
    
    setTimeout(function(){
        this.emit('some-event');
        this.emit('another-event');
        this.emit('post-resolution');
    }, 200)
}));

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