//: [Previous](@previous)

///***** Annonymous functions *****///

/*
 When data is immutable, how do we write functions that, for example, add or remove elements from a list? The answer is simple. When we add an element 1 to the front of an existing list, we return a new list. Since lists are immutable, we don't need to actually copy xs; we can just reuse it.
 */

// example:
func add<T>(_ element: T, list: [T]) -> [T] {
    return list + [element]
}


/*
 EXERCISE: Implement the function tail for "removing" the first element of a List. Notice the function takes constant time. What are different choices you could make in your implementation if the List is Nil? We will return to this question in the next chapter.
 */
func tail<T>(_ list: [T]?) -> [T] where T: Equatable {
    guard let l = list, !l.isEmpty else { return [] }
    return Array(l.dropFirst())
}
print(tail([2, 3, 4, 5, 6]))

/*
 EXERCISE: Generalize tail to the function drop, which removes the first n elements from a list.
 */
func drop<T>(_ elements: Int,  list: [T]?) -> [T] where  T: Equatable {
    guard let l = list, l.count >= elements else { return [] }
    return Array(l.dropFirst(elements))
}
print(drop(3, list: ["Alpha", "Beta", "Charlie", "Delta"]))

/*
 EXERCISE: Implement dropWhile, which removes elements from the List prefix as long as they match a predicate. Again, notice these functions take time proportional only to the number of elements being dropped—we do not need to make a copy of the entire List.
 */
func dropWhile<A>(_ list: [A], f: (A) -> Bool) -> [A] {
    guard list.count > 0 else { return [] }
    return list.filter { f($0) == false }
}
func smallerThanFour(_ a: Int) -> Bool {
    return a < 4
}
dropWhile([1, 2, 3, 4, 5, 6, 7, 8], f: smallerThanFour)

/*
 EXERCISE: Using the same idea, implement the function setHead for replacing the first element of a List with a different value.
 */
func setHead<A>(_ element: A, list: [A]) -> [A] {
    guard !list.isEmpty else { return [element] }
    return [element] + list.dropFirst()
}
setHead(30, list: [1, 2, 3, 4, 5])





///***** Recursion over lists and generalizing to higher-order functions *****///
/*
 Let's look again at the implementations of sum and product. We've simplified the product implementation slightly, so as not to include the "short-circuiting" logic of checking for 0.0:
 */
func sum(_ ints: [Int]?) -> Int {
    guard let l = ints, let head = l.first else { return 0 }
    return head + sum(Array(l.dropFirst()))
}

func product(_ ints: [Int]?) -> Int {
    guard let l = ints, let head = l.first else { return 1 }
    return head * product(Array(l.dropFirst()))
}

/*
 Notice how similar these two definitions are. The only things that differ are the value to return in the case that the list is empty (0 in the case of sum, 1 in the case of product), and the operation to apply to combine results (+ in the case of sum, * in the case of product). Whenever you encounter duplication like this, as we've discussed before, you can generalize it away by pulling subexpressions out into function arguments.
 */

/*
 If a subexpression refers to any local variables (the + operation refers to the local variables `head` and `Array(l.dropFirst())`, similarly for product), turn the subexpression into a function that accepts these variables as arguments. Putting this all together for this case, our function will take as arguments the value to return in the case of the empty list, and the function to add an element to the result in the case of a nonempty list:
 */
// Helper to make it easier to understand fold function
extension Array {
    
    var head: Element? {
        get { return self.first }
    }
    
    var tail: Array<Element>? {
        get {
            if self.isEmpty { return [] }
            return Array(self.dropFirst())
        }
    }
}


func foldRight<A, B>(_ list: [A]?, z: B, f: (A, B) -> B) -> B {
    guard let l = list, let head = l.first else { return z }
    return f(head, foldRight(l.tail, z: z, f: f))
}

func sum2(_ list: [Int]) -> Int {
    return foldRight(list, z: 0, f:(+))
}

func product2(_ list: [Int]) -> Int {
    return foldRight(list, z: 1, f:(*))
}
//print(sum2([1, 2, 3]))
//print(product2([2, 3, 1000, 3]))

/*
EXERCISE: Compute the length of a list using foldRight.
*/

func length<T>(_ list: [T]) -> Int {
    return foldRight(list, z: 0, f: { _, _ in return list.count })
}
print("length: " + "\(length([1, 2, 3, 4]))")
/*
 EXERCISE: foldRight is not tail-recursive and will StackOverflow for large lists. Convince yourself that this is the case, then write another general list-recursion function, foldLeft that is tail-recursive, using the techniques we
 discussed in the previous chapter.
 */
func foldLeft<A, B>(_ list: [A]?, z: B, f: (B, A) -> B) -> B {
    guard let l = list, let tail = l.last else { return z }
    return f(foldLeft(Array(l.dropLast()), z: z, f: f), tail)
}
var list = [1, 2, 3, 4, 5]
print(foldLeft(list, z: 1, f: { $0 + ($1 + 5) }))

/*
 EXERCISE: Implement append in terms of either foldLeft or foldRight.
 */

func append<A>(_ list: [A], element: A) -> [A] {
    return foldRight(list, z: [element], f: add)
}

append(["a", "s", "p"], element: "j")

/*
 EXERCISE: Write a function that transforms a list of integers by adding 1 to each element. (Reminder: this should be a pure function that returns a new List!)
 */
func incr(_ list: [Int]) -> [Int] {
    func i(_ a: Int) -> Int {
        return a + 1
    }
    return list.map(i)
}
incr([1, 2, 3, 4, 5])

/*
 EXERCISE: Write a function that turns each value in a List[Double] into a String.
 */
//func toString(_ list: [Double]) -> [String] {
//    return list.map { String($0) }
//}
func toString(_ list: [Double], f: (Double) -> String) -> [String] {
    var tempArray: [String] = []
    list.forEach { number in tempArray.append(f(number)) }
    return tempArray
}

toString([1.0, 2.0, 3.0], f: { a in return "\(a)"})

/*
 EXERCISE: Write a function map, that generalizes modifying each element in a list while maintaining the structure of the list. Here is its signature:
 
  func map<A,B>(l: [A], f: (A) -> B) -> [B]
 */

func map<A,B>(l: [A], f: (A) -> B) -> [B] {
    var bs: [B] = []
    l.forEach { a in bs.append(f(a)) }
    return bs
}

/*
 EXERCISE: Write a function filter that removes elements from a list unless they satisfy a given predicate. Use it to remote all odd numbers from a List[Int].
 */
func filter<A>(_ l: [A], f: (A) -> Bool) -> [A] {
    var filtered: [A] = []
    l.forEach { a in
        if f(a) == true {
            filtered.append(a)
        }
    }
    return filtered
}

func isEven(n: Int) -> Bool {
    return n % 2 == 0
}
filter([1, 2, 3, 4, 5, 6, 7, 8, 9], f: isEven)




//: [Next](@next)
