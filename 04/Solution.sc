@main def solution(file: String) = {
  val source = scala.io.Source.fromFile(file)
  val costs = source.getLines().map(cardToCost).toList
  source.close

  print("Result 1: ")
  println(costs.map((x: Int) => 1 << (x - 1)).sum)

  val res = costs.
    foldLeft((costs.length, List.fill(costs.length)(1)))
    ((d: (Int, List[Int]), cost: Int) => {
      val e = d(1).head
      val tail = d(1).tail
      (d(0) + e * cost, tail.take(cost).map(_ + e) ++ tail.drop(cost))
    })(0)

  print("Result 2: ")
  println(res)
}

def cardToCost(card: String): Int = {
  val s = card.split("[:|]")
  val targets = s(1).
    trim.
    split("\\s+").
    map(_.toInt).
    toSet
  s(2).
    trim.
    split("\\s+").
    map(_.toInt).
    filter(targets contains _).
    length
}
