Bacon.nodeStream
================

Connecting Node stream with Bacon.EventStream

This document is written in Literate CoffeeScript

    'use strict'

## Install

You can download the latest [generated javascript](https://raw.github.com/hden/Bacon.EventEmitter/master/lib/EventEmitter.bundle.js).

..or you can use script tags to include this file directly from Github:

```
<script src="https://raw.github.com/hden/Bacon.nodeStream/master/lib/Bacon.nodeStream.bundle.js"></script>
```

If you're using node.js, you can

```
npm install https://raw.github.com/hden/Bacon.nodeStream
```

## Dependency

It depends on

* stream
* Bacon

    stream = require 'stream' unless stream?
    Bacon = require 'baconjs' unless Bacon?

Gracefully exit when requirements are not met.

    return unless stream and Bacon

## Initial setup

Save a reference to the global object (window in the browser, exports on the server).

    root = @

## Definitions

    Bacon.nodeStream = {

Takes a readable stream, converts the data flow as an Bacon.EventStream instance.

      fromReadableStream: (stream) ->
        if stream.readable

Pause the stream while configuration, otherwise the data flow will start immediately.
One must explicitely call `stream.resume()` after setting up the pipeline so that data would not be lost.
See http://nodejs.org/api/stream.html#stream_compatibility for detail.

          do stream.pause
        Bacon.fromEventTarget stream, 'data'

Create a readable stream from a Bacon.EventStream instance. We use a passthrough stream to handle
backpressure since currently Bacon.EventStream have no mechanism to handle it.
One may specify `highWaterMark` in the options since it will be pass to the stream constructor.

Tips: One may consider throttling the event stream when piping to slow IO.

      createReadableStream: (eventStream, options) ->
        stream = new stream.PassThrough(options)

Call `unsub()` of the returned stream to unsubscribe all the bindings.

        unsub = -> do unsubFunc for key, unsubFunc of @unsub

Or call the individual property instead.

        unsub.onValue = eventStream.assign stream, 'write'
        unsub.onError = eventStream.onError (err) -> stream.emit 'error', err
        unsub.onEnd = eventStream.onEnd (d) -> stream.emit 'end', d

        stream.unsub = unsub

        return stream
    }

## Export

The top-level namespace. All public classes and modules will be attached to this.
Exported for both the browser and the server.

    if module?
      module.exports = Bacon.nodeStream

Current version of the library. Keep in sync with package.json

    EventEmitter.version = '0.0.1'

## Licence

    ###
    Bacon.EventEmitter: Light-weight Baconized EventEmitter
    Copyright(c) 2013 Hao-kang Den <haokang.den@gmail.com>
    MIT Licenced
    ###
