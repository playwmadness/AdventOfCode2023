using System;
using System.IO;

class Solution {

  const int SIZE = 'Z' - 'A' + 1;
  const int MEGASIZE = SIZE * SIZE * SIZE;

  static int NodeToId(string node) {
    int val = 0;
    foreach (char c in node) {
      val *= SIZE;
      val += c - 'A';
    }
    return val;
  }

  static ulong GCD(ulong l, ulong r) {
    while (l > 0 && r > 0) {
      if (l > r) {
        l %= r;
      } else {
        r %= l;
      }
    }
    return l | r;
  }

  static int Main(string[] args)
  {
    if (args.Length < 1)
    {
      Console.WriteLine("Expected input file path");
      return 1;
    }

    string[] lines = File.ReadAllLines(args[0]);
    var lefts = new int[MEGASIZE];
    var rights = new int[MEGASIZE];

    string path = lines[0];

    for (int i = 2; i < lines.Length; i++)
    {
      string line = lines[i];
      var from = NodeToId(line.Substring(0, 3));
      var left = NodeToId(line.Substring(7, 3));
      var right = NodeToId(line.Substring(12, 3));

      lefts[from] = left;
      rights[from] = right;
    }

    int id = 0;
    int n = path.Length;
    int now = 0;
    while (true) {
      if (path[id % n] == 'R') {
        now = rights[now];
      } else {
        now = lefts[now];
      }

      id++;
      if ((now + 1) % SIZE == 0) {
        break;
      }
    }

    Console.WriteLine($"Result 1: {id}");


    ulong lcm = (ulong)(id);
    for (int i = 1; i < SIZE * SIZE; i++) {
      now = i * SIZE;

      if (rights[now] == 0) {
        continue;
      }

      id = 0;
      while (true) {
        if (path[id % n] == 'R') {
          now = rights[now];
        } else {
          now = lefts[now];
        }

        id++;
        if ((now + 1) % SIZE == 0) {
          break;
        }
      }
      lcm = lcm / GCD(lcm, (ulong)(id)) * (ulong)(id);
    }

    Console.WriteLine($"Result 2: {lcm}");

    return 0;
  }
}
