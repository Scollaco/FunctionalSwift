//: [Previous](@previous)
import UIKit

struct MyModule {
    
    func abs(n: Int) -> Int {
        return n < 0 ? -n : n
    }
    
    func factorial(n: Int) -> Int {
        func go(n: Int, acc: Int) -> Int {
            return n <= 0 ? acc : go(n: n - 1, acc: n * acc)
        }
        return go(n: n, acc: 1)
    }
    
    // Passing a function as argument
    func formateResult(name: String, n: Int, f: (Int) -> Int) -> String {
        return "The \(name) of \(n) is \(f(n))"
    }
    
}

let module = MyModule()
module.formateResult(name: "Abs", n: -5, f: module.abs)
module.formateResult(name: "Factorial", n: 5, f: module.factorial)


///***** Annonymous functions *****///
/*
 Functions get passed around so often in functional programming 
 that it's convenient to have a lightweight way to declare a function, locally, 
 without having to give it a name. In Swift we can pass a closure as argument, for example.
 */

//Example:
let incr = { number in
    number + 1
}
//module.formateResult(name: "increment", n: 7, f: incr)

module.formateResult(name: "increment", n: 7, f: { n in n + 1 })




///***** Polymorphic functions: abstracting over types *****///
/*
Different than monomorphic functions that operates only on type of data - like abs and factorial both:(Int) -> Int and formatResults that's also fixed to operate on functions that take arguments of type Int - polymorphic functions works with any type of data. The example below is a polymorphoc function.
 */

func isSorted<T>(array: [T], compare: (T, T) -> Bool) -> Bool where T: Comparable {
    for i in 0..<array.count - 1 {
        if i > 0 {
            let comp = compare(array[i - 1], array[i])
            if comp == false {
                return comp
            }
        }
    }
    return true
}
isSorted(array: [1, 2, 3, 4, 6, 7], compare: (>))


// Other example:
func partial1<A, B, C>(a: A, f: @escaping(A, B) -> C) -> (B) -> C {
    return { b in
        return f(a, b)
    }
}

struct Person {
    let name: String
    let age: Int
}

func person(name: String, age: Int) -> Person {
    return Person(name: name, age: age)
}
let me = partial1(a: "MyName", f: person)(10)
me.age
me.name


// Example with currying:
func curry<A, B, C>(f: @escaping(A, B) -> C) -> (A) -> ((B) -> C) {
    return { a in
        return { b in
            return f(a, b)
        }
    }
}

let me2 = curry(f: person)("MyOtherName")(15)
me2.age
me2.name


// Example with function composition:
func compose<A, B, C>(f: @escaping(A) -> B, g: @escaping(B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

func toString(i: Int) -> String {
    return "\(i)"
}

func formattedString(s: String) -> String {
    return "The integer passed as parameter was \(s)"
}

let output = compose(f: toString, g: formattedString)
output(5)

//: [Next](@next)
