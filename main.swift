import Foundation

/*
######################################################
# Helper Functions
######################################################
*/
func dotProduct(_ vectorA: [Float], _ vectorB: [Float]) -> Float {
  guard vectorA.count == vectorB.count else { exit(0) }  // should always have the same length
  return zip(vectorA, vectorB).map(*).reduce(0, +)
}
func euclideanNorm(array: [Float]) -> Float {
  let sumOfSquares = array.reduce(0) { sum, element in
    sum + element * element
  }
  return sqrt(sumOfSquares)
}

/*
######################################################
# Part 1 A
######################################################
*/
func genDescent(
  f: ([Float]) -> Float, g: ([Float]) -> [Float], T: ([Float]) -> Float, t: Float,
  initialPoint: [Float], alpha: Float, beta: Float
) -> ([[Float]], [Float]) {
  //logging
  var iter_points: [[Float]] = []
  var iter_evaluated_points: [Float] = []

  //descent params
  var step: Float = 1  //initial
  var x = initialPoint
  var direction = g(x).map { -$0 }
  var maxCount = 10000

  while T(x) > t {  //epsilon
    var oldStep: Float = 0.0
    while true {  //line backtracking
      if f(zip(x, direction).map { $0 + ($1 * step) }) <= f(x) + alpha * step
        * dotProduct(direction.map { -$0 }, direction)
      {
        break
      }
      if step - oldStep < 0.000001 {
        print("backtrack stagnated")
        break
      }
      oldStep = step
      step = step * beta
      print("backtracking step: ", step)
    }
    x = zip(x, direction).map { $0 + ($1 * step) }
    iter_points.append(x)
    iter_evaluated_points.append(f(x))
    direction = g(x).map { -$0 }

    if maxCount > 0 {
      print("Max count not met")
      maxCount = maxCount - 1
    } else {
      break
    }
  }
  return (iter_points, iter_evaluated_points)
}
/*
######################################################
# Part 1 B
######################################################
*/
func function(x: [Float]) -> Float {
  return (0.5) * (pow(x[0], 2) + (2 * pow(x[1], 2)))
}
func function_grad(x: [Float]) -> [Float] {
  return [x[0], 2 * x[1]]
}
func stopping_func(x: [Float]) -> Float {
  return euclideanNorm(array: function_grad(x: x))
}

func part1B() {
  // Part 1B Imple
  let initialCond: [Float] = [12.0, 14.0]
  let epsilon: Float = 0.001
  let alpha: Float = 0.3
  let beta: Float = 0.7
  let result = genDescent(
    f: function, g: function_grad, T: stopping_func, t: epsilon, initialPoint: initialCond,
    alpha: alpha, beta: beta)
  print(result)
}

part1B()
