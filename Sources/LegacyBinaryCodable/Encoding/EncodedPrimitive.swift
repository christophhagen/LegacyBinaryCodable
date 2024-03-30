import Foundation

struct EncodedPrimitive: EncodingContainer {
    
    let dataType: DataType

    let data: Data
    
    let isEmpty: Bool

    init(primitive: EncodablePrimitive) throws {
        self.dataType = primitive.dataType
        self.data = try primitive.data()
        self.isEmpty = false
    }
}
