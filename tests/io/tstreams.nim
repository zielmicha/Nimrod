import streams, io

let myStream = StringStream(data: "hello")
static:
  assert myStream is SyncByteStream
  assert Stream is SyncByteStream
