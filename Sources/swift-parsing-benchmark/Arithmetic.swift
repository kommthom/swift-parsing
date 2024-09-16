@preconcurrency import Benchmark
import Foundation
import Parsing

extension Double: Sendable {}
typealias DoubleDouble = @Sendable (Double, Double) -> Double

/// This benchmark demonstrates how to parse a recursive grammar: arithmetic.
let arithmeticSuite = BenchmarkSuite(name: "Arithmetic") { suite in
  struct AdditionAndSubtraction: ParserProtocol {
    var body: some ParserProtocol<Substring.UTF8View, Double> {
      InfixOperator(associativity: .left) {
        OneOf {
			"+".utf8.map { { $0 + $1 } as DoubleDouble }
			"-".utf8.map { { $0 - $1 } }
        }
      } lowerThan: {
        MultiplicationAndDivision()
      }
    }
  }

  struct MultiplicationAndDivision: ParserProtocol {
    var body: some ParserProtocol<Substring.UTF8View, Double> {
      InfixOperator(associativity: .left) {
        OneOf {
			"*".utf8.map { { $0 * $1 } as DoubleDouble }
			"/".utf8.map { { $0 / $1 } }
        }
      } lowerThan: {
        Exponent()
      }
    }
  }

  struct Exponent: ParserProtocol {
    var body: some ParserProtocol<Substring.UTF8View, Double> {
      InfixOperator(associativity: .left) {
		  "^".utf8.map { { pow($0, $1) } as DoubleDouble }
      } lowerThan: {
        Factor()
      }
    }
  }

  struct Factor: ParserProtocol {
    var body: some ParserProtocol<Substring.UTF8View, Double> {
      OneOf {
        Parse {
          "(".utf8
          AdditionAndSubtraction()
          ")".utf8
        }

        Double.parser()
      }
    }
  }

  let input = "1+2*3/4-5^2"
  var output: Double!
  suite.benchmark("ParserProtocol") {
    var input = input[...].utf8
    output = try AdditionAndSubtraction().parse(&input)
  } tearDown: {
    precondition(output == -22.5)
  }
}

public struct InfixOperator<Input: Sendable, Operator: ParserProtocol, Operand: ParserProtocol>: ParserProtocol where Operator.Input == Input, Operand.Input == Input, Operator.Output == @Sendable (Operand.Output, Operand.Output) -> Operand.Output
{
  public let `associativity`: Associativity
  public let operand: Operand
  public let `operator`: Operator

  @inlinable
  public init(
    associativity: Associativity,
    @ParserBuilder<Input> _ operator: @Sendable () -> Operator,
    @ParserBuilder<Input> lowerThan operand: @Sendable () -> Operand  // Should this be called `precedes:`?
  ) {
    self.associativity = `associativity`
    self.operand = operand()
    self.operator = `operator`()
  }

  @inlinable
  public func parse(_ input: inout Input) rethrows -> Operand.Output {
    switch associativity {
    case .left:
      var lhs = try self.operand.parse(&input)
      var rest = input
      while true {
        do {
          let operation = try self.operator.parse(&input)
          let rhs = try self.operand.parse(&input)
          rest = input
          lhs = operation(lhs, rhs)
        } catch {
          input = rest
          return lhs
        }
      }
    case .right:
      var lhs: [(Operand.Output, Operator.Output)] = []
      while true {
        let rhs = try self.operand.parse(&input)
        do {
          let operation = try self.operator.parse(&input)
          lhs.append((rhs, operation))
        } catch {
          return lhs.reversed().reduce(rhs) { rhs, pair in
            let (lhs, operation) = pair
            return operation(lhs, rhs)
          }
        }
      }
    }
  }
}

public enum Associativity: Sendable {
  case left
  case right
}
