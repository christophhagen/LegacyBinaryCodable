import Foundation

/**
 A protocol to provide continuous data for decoding.

 This protocol can be used in conjuction with ``LegacyBinaryStreamDecoder`` to decode longer data streams of sequential elements.
 This can be helpful when either the data is not immediatelly available all at once (e.g. when receiving data over a network)
 or when the data is too large to keep it in memory (e.g. when reading a large file).

 Implement this protocol according to the data source for encoded data, and then pass it to a ``LegacyBinaryStreamDecoder`` to decode individual elements.
 - Note: Successful decoding is only possible if the data stream is also encoded using a ``BinaryStreamEncoder``.
 */
protocol BinaryStreamProvider {

    /**
     A callback to the data source to get the next chuck of data as required by the current decoding step.

     The data should be provided in a best-effort manner, if they are available.
     If insufficient bytes are available, e.g. if network data is still in transit,
     then a ``DecodingError`` of type `dataCorrupted` should be thrown.
     This signals to the decoder that not all data is available,
     so that decoding can continue once more data is available.
     - Note: There is no need to buffer incoming data until an element is successfully decoded.
     Any bytes passed to the decoder as the result of this function are internally buffered and can be discarded.

     - Parameter count: The number of bytes to provide as the result.
     - Returns: The next `count` bytes in the data stream.
     */
    func getBytes(_ count: Int, path: [CodingKey]) throws -> Data

    /**
     Indicate if there are any bytes to read for the decoder.

     If the data stream has at least one byte available, then this function should return `true`.
     The decoder uses this function to check if an attempt should be made to decode more elements.

     - Note: There is no need to buffer incoming data until an element is successfully decoded.
     It is safe to return `true`, even if not enough bytes are available to decode a full element.

     - Returns: `true`, if bytes are available for decoding.
     */
    var hasMoreBytes: Bool { get }
}

extension BinaryStreamProvider {

    func getByte(path: [CodingKey]) throws -> UInt8 {
        let data = try getBytes(1, path: path)
        return data[data.startIndex]
    }

    func getDataOfVarint(path: [CodingKey]) throws -> Data {
        var result = [UInt8]()
        for _ in 0...7 {
            let byte = try getByte(path: path)
            result.append(byte)
            if byte & 0x80 == 0 {
                return Data(result)
            }
        }
        let byte = try getByte(path: path)
        result.append(byte)
        return Data(result)
    }

    func getVarint(path: [CodingKey]) throws -> Int {
        let data = try getDataOfVarint(path: path)
        return try .init(fromVarint: data, path: path)
    }

    func getData(for dataType: DataType, path: [CodingKey]) throws -> Data {
        switch dataType {
        case .variableLengthInteger:
            return try getDataOfVarint(path: path)
        case .byte:
            return try getBytes(1, path: path)
        case .twoBytes:
            return try getBytes(2, path: path)
        case .variableLength:
            let count = try getVarint(path: path)
            guard count >= 0 else {
                throw DecodingError.invalidDataSize(path)
            }
            return try getBytes(count, path: path)
        case .fourBytes:
            return try getBytes(4, path: path)
        case .eightBytes:
            return try getBytes(8, path: path)
        }
    }
}
