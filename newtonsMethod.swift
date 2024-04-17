import Foundation

//function param
let gamma:Float = 8;

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

func writeToCsv(fileName: String, line: String) {
    print(fileName)
    if !FileManager.default.fileExists(atPath: fileName) {
        FileManager.default.createFile(atPath: fileName, contents: nil)
    }

    if let fileHandle = FileHandle(forWritingAtPath: fileName) {
        defer {
            fileHandle.closeFile()
        }
        fileHandle.seekToEndOfFile()
        if let data = line.data(using: .utf8) {
            fileHandle.write(data)
        }
    } else {
        exit(1)
    }
}


/*
######################################################
# Part 1 C
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
  var maxCount = 100


//instead of epsilon use the newton decrement as the stopping condition

  while abs(T(x)) > t {  //epsilon
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
    print("Direction", direction)
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
# Part 1 C
######################################################
*/
func function(x: [Float]) -> Float {
  return (0.5) * (pow(x[0], 2) + (gamma * pow(x[1], 2)))
}
func function_grad(x: [Float]) -> [Float] { 
  //x - (∇^(2)f(x)^(-1))*(∇f(x)^(-1)) 
  return [x[0], gamma * x[1]]
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
func newtons_direction(x: [Float]) -> [Float] {
    let gradient = [x[0], gamma * x[1]]
    let direction = [gradient[0], 0.5 * gradient[1]]
    print("Direction from func", direction)    
    return direction
}

func stopping_func(x: [Float]) -> Float { // will now be newtons decrement
  //(∇^(2)f(x)^(-1))*||(∇f(x))|| 
  // or 
  //(∇f(x)^T)*(∇^(2)f(x)^(-1))*(∇f(x)) 
  let grad = function_grad(x: x)
  let grad_transpose = [[grad[0], grad[1]]]
  let hessian = function_hessian(x: x)
  let inverse_hessian = inverse_2_2_mat(mat_og: hessian)
  let first_product = matrixMultiply(inverse_hessian, [[grad[0]], [grad[1]]])
  guard let first_product = first_product else {
       print("bad grad transpose x hessian")
       exit(0) 
  }
  let second_product = matrixMultiply(first_product, grad_transpose) 
  guard let second_product = second_product else {
       print("bad grad transpose x hessian product by grad")
       exit(0) 
  }
  return second_product[0][0]
}

func part1C() { // Part 1B Imple
  let initialCond: [Float] = [12.0, 14.0]
  let epsilon: Float = 0.0001
  let alpha: Float = 0.3
  let beta: Float = 0.7
  let result = genDescent(
    f: function, g: newtons_direction, T: stopping_func, t: epsilon, initialPoint: initialCond,
    alpha: alpha, beta: beta)
  print(result)
  let csv_file = "newton_method_results_gamma_\(gamma).csv"
  let csv_row = "iteration, x, y, value\n"
  writeToCsv(fileName: csv_file, line: csv_row)

  for (n, line) in result.0.enumerated() {
      let csv_row = "\(n),\(line[0]),\(line[1]),\(result.1[n])\n"
      writeToCsv(fileName: csv_file, line: csv_row)
  }

}

part1C()
