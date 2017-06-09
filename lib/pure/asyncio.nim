import asyncfutures, nativesockets

export asyncfutures.Future
export nativesockets.SocketHandle

# Asynchronous I/O

type
  ByteOutput* = concept x
    ## Writes data from view into the output. Returns number of bytes written.
    x.write(ByteView) is Future[int]

    ## Closes the output.
    x.close

  ByteInput* = concept x
    ## Reads data into the buffer. Returns number of bytes read.
    x.read(ByteView) is Future[int]

    ## Closes the input.
    x.close

  ByteStream* = concept x
    x is ByteOutput
    x is ByteInput

# TODO: ByteStream should also automatically be SyncByteStream, but for that we need to have loop-independent ``waitFor``.

type
  AsyncLoop* = concept x
    ## Perform some work on the event loop
    x.runOnce

    ## These function wrap native (OS) handle in an async stream.
    x.wrapHandleAsInput(SocketHandle) is ByteInput
    x.wrapHandleAsOutput(SocketHandle) is ByteOutput
    x.wrapHandleAsStream(SocketHandle) is ByteStream
