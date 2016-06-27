import Foundation
import zlib

func downloadTestData() -> (images: NSData, labels: NSData) {
    let baseUrl = "http://yann.lecun.com/exdb/mnist/"
    
    let testImages = NSData(contentsOfURL: NSURL(string: baseUrl)!.URLByAppendingPathComponent("t10k-images-idx3-ubyte.gz"))!
    let testLabels = NSData(contentsOfURL: NSURL(string: baseUrl)!.URLByAppendingPathComponent("t10k-labels-idx1-ubyte.gz"))!

    return (images: ungzip(testImages)!, labels: ungzip(testLabels)!)
}

private func ungzip(source: NSData) -> NSData? {
    guard source.length > 0 else {
        return nil
    }
    
    var stream: z_stream = z_stream.init(next_in: UnsafeMutablePointer<Bytef>(source.bytes), avail_in: uint(source.length), total_in: 0, next_out: nil, avail_out: 0, total_out: 0, msg: nil, state: nil, zalloc: nil, zfree: nil, opaque: nil, data_type: 0, adler: 0, reserved: 0)
    guard inflateInit2_(&stream, MAX_WBITS + 32, ZLIB_VERSION, Int32(sizeof(z_stream))) == Z_OK else {
        return nil
    }
    
    let data = NSMutableData()
    
    while stream.avail_out == 0 {
        let bufferSize = 0x10000
        let buffer: UnsafeMutablePointer<Bytef> = UnsafeMutablePointer.alloc(bufferSize)
        stream.next_out = buffer
        stream.avail_out = uint(sizeofValue(buffer))
        inflate(&stream, Z_FINISH)
        let length: size_t = sizeofValue(buffer) - Int(stream.avail_out)
        if length > 0 {
            data.appendBytes(buffer, length: length)
        }
        buffer.dealloc(bufferSize)
    }
    
    inflateEnd(&stream)
    return NSData(data: data)
}