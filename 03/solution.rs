use std::collections::HashMap;
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
    let n = input.len();

    let mut stats: HashMap<(usize, usize), Option<Vec<i32>>> = HashMap::new();
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
                    val = 0;
                }

                id = j;

                if c != '.' {
                    let mut ins = None;
                    if c == '*' {
                        ins = Some(vec![]);
                    }
                    stats.insert((i, j), ins.take());
                }
            }
        }
    }

    let mut res = 0;

    for num in nums {
        let mut ok = false;

        let mut visit: Vec<(usize, usize)> = vec![(num.line, num.left), (num.line, num.right)];

        if num.line > 0 {
            visit.extend(
                (num.left..=num.right)
                    .into_iter()
                    .map(|x| (num.line - 1, x)),
            );
        }
        if num.line + 1 < n {
            visit.extend(
                (num.left..=num.right)
                    .into_iter()
                    .map(|x| (num.line + 1, x)),
            );
        }

        for (i, j) in visit {
            match (stats.get_mut(&(i, j)), ok) {
                (Some(None), false) => {
                    ok = true;
                    res += num.val;
                }
                (Some(Some(v)), false) => {
                    ok = true;
                    res += num.val;
                    v.push(num.val);
                }
                (Some(Some(v)), true) => {
                    v.push(num.val);
                }
                _ => (),
            };
        }
    }

    println!("Result 1: {res}");

    let mut res2 = 0;
    for v in stats.into_values().flatten() {
        if v.len() == 2 {
            res2 += v[0] * v[1];
        }
    }

    println!("Result 2: {res2}");
}
