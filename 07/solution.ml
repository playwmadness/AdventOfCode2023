let lines = String.split_on_char '\n';;
let words = String.split_on_char ' ';;
let head = function
  | x :: _ -> x
  | _ -> failwith "Trying to take head of empty list"
;;
let tail = function
  | _ :: xs -> xs
  | _ -> failwith "Trying to take tail of empty list"
;;
let fst = function
  | x, _ -> x
;;
let snd = function
  | _, x -> x
;;

let group lst = 
  let sl = List.sort compare lst in
  match sl with
  | [] -> ([], 0)
  | hd :: tl -> 
    let jok = if hd = '0' then 1 else 0 in
    let acc, jok_acc, _, c = 
      List.fold_left 
        (fun (acc, jok_acc, x, c) y -> 
          if y = '0'
          then acc, jok_acc + 1, x, c
          else if x = y
          then acc, jok_acc, x, c + 1 
          else c::acc, jok_acc, y, 1) 
        ([], jok, hd, 1 - jok) 
        tl 
    in
    (List.sort compare (c :: acc)), jok_acc
;;

let string_to_list x = String.to_seq x |> List.of_seq;;
let list_to_string = List.fold_left (fun acc x -> acc ^ string_of_int x) ""

let sorted_group lst =
  group lst 
  |> (fun x -> (fst x |> List.rev), snd x)
  |> (fun x -> (fst x |> head |> (fun y -> snd x + y)) :: (fst x |> tail)) 
  |> List.filter (fun x -> x <> 0)
;;

let mapcards joker = function
  | 'A' -> 'E'
  | 'K' -> 'D'
  | 'Q' -> 'C'
  | 'J' -> if joker then '0' else 'B'
  | 'T' -> 'A'
  | x -> x
;;

let line_to_value joker bid = 
  let maphand = 
    bid 
    |> words 
    |> head 
    |> String.map (mapcards joker)
  in
  maphand
  |> string_to_list
  |> sorted_group
  |> list_to_string
  |> (fun x -> x ^ maphand)
;;

let compare_values joker lhs rhs =
  let f = line_to_value joker in
  let lh = f lhs in
  let rh = f rhs in
  compare lh rh
;;

let readfile path =
  let f = open_in path in
  let input = really_input_string f (in_channel_length f) in
  close_in f;
  input
;;

let solve joker inp = inp
  |> lines
  |> List.rev
  |> tail
  |> List.sort (compare_values joker)
  |> List.mapi 
    (
      fun i x -> words x 
      |> tail 
      |> head 
      |> int_of_string 
      |> (fun x -> x * (i + 1))
    )
  |> List.fold_left (fun acc x -> acc + x) 0
;;

let () = 
  if Array.length Sys.argv < 2 then begin
    Printf.printf "Expected input file path\n";
    exit 1;
    end;

  let inp = readfile Sys.argv.(1) in
  Printf.printf 
    "Result 1: %d\nResult 2: %d\n"
    (solve false inp)
    (solve true inp)
