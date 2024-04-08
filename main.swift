
import Foundation

func dotProduct(_ vectorA: [Float], _ vectorB: [Float]) -> Float {
    guard vectorA.count == vectorB.count else {exit(0)} // should always have the same length
    return zip(vectorA, vectorB).map(*).reduce(0, +)
}
func euclideanNorm(array: [Float]) -> Float {
    let sumOfSquares = array.reduce(0) { sum, element in
        sum + element * element
    }
    return sqrt(sumOfSquares)
}

func genDescent(f: (Array<Float>)->Float, g: (Array<Float>)-> Array<Float>, T: (Array<Float>)->Float, t: Float, initialPoint: Array<Float>, alpha: Float, beta: Float) -> (Array<Array<Float>>, Array<Float>){
    //logging
    var iter_points: Array<Array<Float>> = [];
    var iter_evaluated_points: Array<Float> = [];

    //descent params
    var step: Float = 1; //initial
    //var direction: Array<Float> = g(initialPoint); 
    var x = initialPoint; 
    var direction = g(x).map { -$0 }

    var maxCount = 100;

    while T(x) > t { //epsilon 
        //step = 1.0 // Reset step size for each iteration
        var oldStep: Float = 0.0;
        while true { //line backtracking
            if f(zip(x, direction).map { $0 + ($1*step) }) <= f(x) + alpha * step * dotProduct(direction.map {-$0}, direction){
                break;
            }
            if step-oldStep < 0.000001 {
                print("backtrack stagnated")
                break;
            }
            oldStep = step;
            step = step*beta;
            print("backtracking step: ", step);
        }
        print(x)
        x = zip(x, direction).map {$0 + ($1*step)}; 
        iter_points.append(x);
        iter_evaluated_points.append(f(x));
        direction = g(x).map { -$0 }
        
        //print("step: ", step);
        if maxCount > 0 {
            print("Max count not met")
            maxCount = maxCount - 1;
        } else {
            break;
        }
    }
    
    return (iter_points, iter_evaluated_points);
}


//1 B test
func function(x: Array<Float>) -> Float {
    return (0.5) * (pow(x[0], 2) + (2 * pow(x[1], 2)));
}
/*
func function_grad(x: Array<Float>) -> Array<Float> {
    var result: Array<Float> = [];
    result.append((0.5)*((x[0] * 2) - (2 * pow(x[1], 2))));
    result.append((0.5)*(pow(x[0], 2) - (2 * (x[1] * 2))));
    return result;
}
*/

func function_grad(x: Array<Float>) -> Array<Float> {
    return [x[0], 2*x[1]];
}

func stopping_func (x: Array<Float>) -> Float {
    return euclideanNorm(array: function_grad(x: x));
}
func main() {

var initialCond: Array<Float> = [12.0, 14.0];
var epsilon: Float = 0.001;
var alpha: Float = 0.3;
var beta: Float = 0.7;

var direction = function_grad(x: initialCond)

print(direction)


print(function_grad(x: initialCond).map { -$0 })



let result = genDescent(f: function, g: function_grad, T: stopping_func, t: epsilon, initialPoint: initialCond, alpha: alpha, beta: beta);

print(result);

}

main();
