//
//  TypeErasure.swift
//  AdvancedSwift
//
//  Created by 常仲伟 on 2021/11/14.
//

import Foundation

public protocol IteratorProtocol {
  associatedtype Element
  mutating func next() -> Element?
}

struct ConstantIterator: IteratorProtocol {
  mutating func next() -> Int? {
    return 1
  }
}

/*
 Protocol 'IteratorProtocol' can only be used as a generic constraint
 because it has Self or associated type requirements
 */
//let iterator: IteratorProtocol = ConstantIterator() // Error

//我们可以将 IteratorProtocol ⽤作泛型参数的约束：
func nextInt<I: IteratorProtocol>(iterator: inout I) -> Int? where I.Element == Int {
  return iterator.next()
}

/*
 类似地，我们可以将迭代器保存在⼀个类或者结构体中。
 这⾥的限制也是⼀样的，我们只能够 将它⽤作泛型约束，⽽不能⽤作独⽴的类型：
*/
class IteratorStore<I: IteratorProtocol> where I.Element == Int {
  var iterator: I
  init(iterator: I) {
    self.iterator = iterator
  }
}
//这是可⾏⽅式，但是却有⼀个缺点，存储的迭代器的指定类型通过泛型参数 “泄漏” 出来了。

/*
 幸运的是，我们有两种⽅式来绕开这个限制，其中⼀种很简单，另⼀种则更⾼效 (但是⽐较取 巧)。
 将 (迭代器这样的) 指定类型移除的过程，就被称为类型抹消。
 简单的解决⽅式是实现⼀个封装类。我们不直接存储迭代器，⽽是让封装类存储迭代器的 next 函数。
 要做到这⼀点，我们必须⾸先将 iterator 参数复制到⼀个本地的 var 变量中，这样我们 就可以调⽤它的 mutating 的 next ⽅法了。
 接下来我们将 next() 的调⽤封装到闭包表达式中， 然后将这个闭包赋值给属性。我们使⽤类来表征 IntIterator 具有引⽤语义：
 */
class IntIterator: IteratorProtocol {
  var nextImpl: () -> Int?

  init<I>(_ iterator: I) where I.Element == Int, I : IteratorProtocol {
    var iteratorCopy = iterator
    self.nextImpl = { iteratorCopy.next() }
  }
  func next() -> Int? {
    return nextImpl()
  }
}

fileprivate func test0() {
  var iter = IntIterator(ConstantIterator())
  let k = AnyIterator([1,2,3].makeIterator())
  
  let iter = IntIterator(AnyIterator({
    return 1
  }))//([1,2,3].makeIterator())
}

//class AnyIterator<Element>: IteratorProtocol {
//  var nextImpl: () -> Element?
//
//  init<I: IteratorProtocol>(_ iterator: I) where I.Element == A {
//    var iteratorCopy = iterator
//    self.nextImpl = {
//      iteratorCopy.next()
//    }
//  }
//
//  func next() -> A? {
//    return nextImpl()
//  }
//}
