//
//  Extensions.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import Foundation
import CommonCrypto

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
import SwiftUI

extension View {
    
    /// Reads the view frame and bind it to the reader.
    /// - Parameters:
    ///   - coordinateSpace: a coordinate space for the geometry reader.
    ///   - reader: a reader of the view frame.
    func readFrame(in coordinateSpace: CoordinateSpace = .global,
                   for reader: Binding<CGRect>) -> some View {
        readFrame(in: coordinateSpace) { value in
            reader.wrappedValue = value
        }
    }
    
    /// Reads the view frame and send it to the reader.
    /// - Parameters:
    ///   - coordinateSpace: a coordinate space for the geometry reader.
    ///   - reader: a reader of the view frame.
    func readFrame(in coordinateSpace: CoordinateSpace = .global,
                   for reader: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(
                        key: FramePreferenceKey.self,
                        value: geometryProxy.frame(in: coordinateSpace)
                    )
                    .onPreferenceChange(FramePreferenceKey.self, perform: reader)
            }
        )
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue = CGRect.zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
