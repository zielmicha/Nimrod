import views
# Synchronous I/O

# needed for concepts
export ByteView

type
  SyncByteOutput* = concept x
    ## Writes data from view into the output. Returns number of bytes written.
    ##
    ## Return value of 0 indicates end of file.
    x.writeSync(ByteView) is int

    ## Closes the output.
    x.close

  SyncByteInput* = concept x
    ## Reads data into the buffer. Returns number of bytes read.
    ##
    ## Return value of 0 indicates end of file.
    x.readSync(ByteView) is int

    ## Closes the input.
    x.close

  SyncByteStream* = concept x
    x is SyncByteOutput
    x is SyncByteInput

proc writeAllSync*(stream: SyncByteOutput, data: ByteView) =
  var data = data
  while data.len > 0:
    let nwrite = stream.writeSync(data)
    if nwrite == 0:
      raise newException(IOError, "EOF")

    data = data.slice(nwrite)

proc readAllSync*(stream: SyncByteInput, data: ByteView) =
  var data = data
  while data.len > 0:
    let nread = stream.readSync(data)
    if nread == 0:
      raise newException(IOError, "EOF")

    data = data.slice(nread)
