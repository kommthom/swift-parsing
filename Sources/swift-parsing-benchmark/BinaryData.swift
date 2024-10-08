@preconcurrency import Benchmark
import Foundation
import Parsing

/// This benchmark demonstrates how to parse raw data, which is just a collection of `UInt8` values
/// (bytes).
///
/// The data format we parse is the header for DNS packets, as specified
/// [here](https://tools.ietf.org/html/rfc1035#page-26). It consists of 12 bytes, and contains
/// information for 13 fields:
///
///     0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
///     |                      ID                       |
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
///     |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
///     |                    QDCOUNT                    |
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
///     |                    ANCOUNT                    |
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
///     |                    NSCOUNT                    |
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
///     |                    ARCOUNT                    |
///     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
let binaryDataSuite = BenchmarkSuite(name: "BinaryData") { suite in
  #if swift(>=5.8)
    struct Word16Parser: ParserProtocol {
      func parse(_ input: inout ArraySlice<UInt8>) throws -> UInt16 {
        guard input.count >= 2
        else {
          struct ParsingError: Error {}
          throw ParsingError()
        }
        let output = UInt16(input[input.startIndex]) + UInt16(input[input.startIndex + 1]) << 8
        input.removeFirst(2)
        return output
      }
    }

    struct DNSHeaderParser: ParserProtocol {
      var body: some ParserProtocol<ArraySlice<UInt8>, DNSHeader> {
        Parse { id, fields1, fields2, counts in
          DNSHeader(
            id: id,
            qr: fields1.qr,
            opcode: fields1.opcode,
            aa: fields1.aa,
            tc: fields1.tc,
            rd: fields1.rd,
            ra: fields2.ra,
            z: fields2.z,
            rcode: fields2.rcode,
            qdcount: counts.qd,
            ancount: counts.an,
            nscount: counts.ns,
            arcount: counts.ar
          )
        } with: {
          Word16Parser()

          First().map { byte in
            (
              qr: Bit(rawValue: byte & 0b00000001)!,
              opcode: Opcode(rawValue: (byte & 0b00011110) >> 1),
              aa: Bit(rawValue: (byte & 0b00100000) >> 5)!,
              tc: Bit(rawValue: (byte & 0b01000000) >> 6)!,
              rd: Bit(rawValue: (byte & 0b10000000) >> 7)!
            )
          }

          First().map { byte in
            (
              ra: Bit(rawValue: byte & 0b00000001)!,
              z: UInt3(uint8: (byte & 0b00001110) >> 1)!,
              rcode: Rcode(rawValue: (byte & 0b11110000) >> 4)
            )
          }

          Parse {
            (qd: $0, an: $1, ns: $2, ar: $3)
          } with: {
            Word16Parser()
            Word16Parser()
            Word16Parser()
            Word16Parser()
          }
        }
      }
    }

    let input: [UInt8] = [
      // header
      42, 142,
      0b10100011, 0b00110000,
      128, 0,
      100, 200,
      254, 1,
      128, 128,

      // rest of packet
      0xDE, 0xAD, 0xBE, 0xEF,
    ]
    var output: DNSHeader!
    var rest: ArraySlice<UInt8>!

    suite.benchmark("ParserProtocol") {
      var input = input[...]
      output = try DNSHeaderParser().parse(&input)
      rest = input
    } tearDown: {
      precondition(
        output
          == DNSHeader(
            id: 36_394,
            qr: .one,
            opcode: .inverseQuery,
            aa: .one,
            tc: .zero,
            rd: .one,
            ra: .zero,
            z: UInt3(uint8: 0)!,
            rcode: .nameError,
            qdcount: 128,
            ancount: 51_300,
            nscount: 510,
            arcount: 32_896
          )
      )
      precondition(rest == [0xDE, 0xAD, 0xBE, 0xEF])
    }

    struct DNSHeader: Equatable {
      let id: UInt16
      let qr: Bit
      let opcode: Opcode
      let aa: Bit
      let tc: Bit
      let rd: Bit
      let ra: Bit
      let z: UInt3
      let rcode: Rcode
      let qdcount: UInt16
      let ancount: UInt16
      let nscount: UInt16
      let arcount: UInt16
    }

    enum Bit: Equatable {
      case zero, one

      init?(rawValue: UInt8) {
        if rawValue == 0 {
          self = .zero
        } else if rawValue == 1 {
          self = .one
        } else {
          return nil
        }
      }
    }

    struct UInt3: Equatable {
      let bit0: Bit
      let bit1: Bit
      let bit2: Bit

      init?(uint8: UInt8) {
        guard
          uint8 & 0b11111000 == 0,
          let bit0 = Bit(rawValue: uint8 & 0b001),
          let bit1 = Bit(rawValue: uint8 & 0b010),
          let bit2 = Bit(rawValue: uint8 & 0b100)
        else { return nil }

        self.bit0 = bit0
        self.bit1 = bit1
        self.bit2 = bit2
      }
    }

    struct Rcode: Equatable, RawRepresentable {
      let rawValue: UInt8

      static let noError = Self(rawValue: 0)
      static let formatError = Self(rawValue: 1)
      static let serverFailure = Self(rawValue: 2)
      static let nameError = Self(rawValue: 3)
      static let notImplemented = Self(rawValue: 4)
      static let refused = Self(rawValue: 5)
    }

    struct Opcode: Equatable, RawRepresentable {
      let rawValue: UInt8

      static let standardQuery = Self(rawValue: 0)
      static let inverseQuery = Self(rawValue: 1)
      static let status = Self(rawValue: 2)
    }
  #endif
}
