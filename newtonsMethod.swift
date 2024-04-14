import Foundation

//function param
let gamma:Float = 2.0;

/*
######################################################
# Helper Functions
######################################################
*/
func dotProduct(_ vectorA: [Float], _ vectorB: [Float]) -> Float {
  guard vectorA.count == vectorB.count else { exit(0) }  // should always have the same length else throw error 
  return zip(vectorA, vectorB).map(*).reduce(0, +)
}
func euclideanNorm(array: [Float]) -> Float {
  let sumOfSquares = array.reduce(0) { sum, element in
    sum + element * element
  }
  return sqrt(sumOfSquares)
}
func matrixMultiply(_ matrixA: [[Float]], _ matrixB: [[Float]]) -> [[Float]]? {
    let rowsA = matrixA.count
    let colsA = matrixA.first?.count ?? 0
    let rowsB = matrixB.count
    let colsB = matrixB.first?.count ?? 0

    // Check if the multiplication is possible
    if colsA != rowsB {
        print("Error: Number of columns in the first matrix must equal the number of rows in the second matrix.")
        return nil
    }

    // Initialize the result matrix with zeros
    var resultMatrix = Array(repeating: Array(repeating: Float(0), count: colsB), count: rowsA)

    // Perform matrix multiplication
    for i in 0..<rowsA {
        for j in 0..<colsB {
            for k in 0..<colsA {
                resultMatrix[i][j] += matrixA[i][k] * matrixB[k][j]
            }
        }
    }

    return resultMatrix
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


//instead of epsilon use the newton decrement as the stopping condition

  while T(x) > t {  //epsilon
    while true {  //line backtracking
      if f(zip(x, direction).map { $0 + ($1 * step) }) <= f(x) + alpha * step
        * dotProduct(direction.map { -$0 }, direction)
      {
        break
      }
      //oldStep = step
      step = step * beta
      print("backtracking step: ", step)
    }
    x = zip(x, direction).map { $0 + ($1 * step) }
    iter_points.append(x)
    iter_evaluated_points.append(f(x))

    //direction not g(x) (which is currently the gradient) instead use the newton step
    //so the direction can be replaced with a function that involves the hessian
    //question: does the hessian need to be recalculated each time
        //though-> no since we just need to substitute x for x_k
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
# Part 1 C
######################################################
*/
func function(x: [Float]) -> Float {
  return (0.5) * (pow(x[0], 2) + (gamma * pow(x[1], 2)))
}
func function_grad(x: [Float]) -> [Float] { 
  //x - (∇^(2)f(x)^(-1))*(∇f(x)^(-1)) 
  return [x[0], 2 * x[1]]
}
func function_hessian(x: [Float]) -> [[Float]] {
    return [[1.0,0.0],[0.0,gamma]]
}
func inverse_2_2_mat(mat_og: [[Float]]) -> [[Float]]{
    var mat = mat_og
    let const = (mat[0][0] * mat[1][1] -  mat[0][1] * mat[1][0])
    let temp = mat[0][0] 
    mat[0][0] = mat[1][1]
    mat[1][1] = temp
    mat[0][1] = mat[0][1] * -1
    mat[1][1] = mat[1][1] * -1
    return mat.map { $0.map{ $0 / const } }
}
func newtons_step(x: [Float]) -> [Float] {
    let grad = function_grad(x: x)
    let hessian = function_hessian(x: x)
    let inverse_hessian = inverse_2_2_mat(mat_og: hessian) 
    
    let grad_x_hessian = matrixMultiply(inverse_hessian, [[grad[0]],[grad[1]]])

    print(grad_x_hessian)    
 
    //x - (∇^(2)f(x)^(-1))*(∇f(x)^(-1)) 
    guard let grad_x_hessian = grad_x_hessian else {
       print("bad grad x hessian")
       exit(0) 
    }

    return [x[0]-grad_x_hessian[0][0], x[1]-grad_x_hessian[1][0]]
    //return grad 
}
func stopping_func(x: [Float]) -> Float { // will now be newtons decrement

  return euclideanNorm(array: function_grad(x: x))
}

func part1B() { // Part 1B Imple
  let initialCond: [Float] = [12.0, 14.0]
  let epsilon: Float = 0.001
  let alpha: Float = 0.3
  let beta: Float = 0.7
  let result = genDescent(
    f: function, g: newtons_step, T: stopping_func, t: epsilon, initialPoint: initialCond,
    alpha: alpha, beta: beta)
  print(result)
}

part1B()
