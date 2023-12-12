use std::collections::{HashMap, HashSet};
use std::env;
use std::fs;

struct Num {
    val: i32,
    left: usize,
    right: usize,
    line: usize,
}

impl Num {
    fn new(val: i32, left: usize, right: usize, line: usize) -> Self {
        Num {
            val: val,
            left: left,
            right: right,
            line: line,
        }
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        panic!("Expected input file path");
    }

    let input = match fs::read_to_string(&args[1]) {
        Err(_) => panic!("Failed to read input file"),
        Ok(res) => res,
    };
    let input: Vec<String> = input.lines().map(|x| x.into()).collect();

    let mut stats: HashSet<(usize, usize)> = HashSet::new();
    let mut gears: HashMap<(usize, usize), Vec<i32>> = HashMap::new();
    let mut nums: Vec<Num> = vec![];
    for (i, line) in input.into_iter().enumerate() {
        let mut id = 0;
        let mut val = 0;

        for (j, c) in line.chars().chain(std::iter::once('.')).enumerate() {
            if c.is_numeric() {
                val = val * 10 + c as i32 - '0' as i32;
            } else {
                if val > 0 {
                    nums.push(Num::new(val, id, j, i));
                }

                val = 0;
                id = j;

                if c != '.' {
                    stats.insert((i, j));
                    if c == '*' {
                        gears.insert((i, j), vec![]);
                    }
                }
            }
        }
    }

    let mut res = 0;

    for n in nums {
        let mut ok = false;
        for i in (n.line.max(1) - 1)..=(n.line + 1) {
            for j in n.left..=n.right {
                if !ok && stats.contains(&(i, j)) {
                    ok = true;
                    res += n.val;
                }

                match gears.get_mut(&(i, j)) {
                    None => (),
                    Some(v) => v.push(n.val),
                };
            }
        }
    }

    println!("Result 1: {res}");

    let mut res2 = 0;
    for v in gears.into_values() {
        if v.len() == 2 {
            res2 += v[0] * v[1];
        }
    }

    println!("Result 2: {res2}");
}
