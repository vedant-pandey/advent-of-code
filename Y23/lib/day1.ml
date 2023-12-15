open Core

let lines = Utils.read_lines "./inputs/day1"

let first =
  Int.to_string
  @@ List.fold lines ~init:0 ~f:(fun acc line ->
    let chars = String.to_list line in
    let numbers = List.filter chars ~f:Char.is_digit in
    let number =
      Int.of_string @@ Fmt.str "%c%c" (List.hd_exn numbers) (List.last_exn numbers)
    in
    acc + number)
;;

let second =
  let vals =
    [ "one", "1"
    ; "two", "2"
    ; "three", "3"
    ; "four", "4"
    ; "five", "5"
    ; "six", "6"
    ; "seven", "7"
    ; "eight", "8"
    ; "nine", "9"
    ; "1", "1"
    ; "2", "2"
    ; "3", "3"
    ; "4", "4"
    ; "5", "5"
    ; "6", "6"
    ; "7", "7"
    ; "8", "8"
    ; "9", "9"
    ]
  in
  let str_of_f_and_l li = Fmt.str "%s%s" (List.hd_exn li) (List.last_exn li) in
  lines
  |> List.fold ~init:0 ~f:(fun acc line ->
    String.length line
    |> List.range 0
    |> List.filter_map ~f:(fun pos ->
      vals
      |> List.find_map ~f:(fun (pattern, value) ->
        match String.substr_index ~pos line ~pattern with
        | Some match_pos when match_pos = pos -> Some value
        | _ -> None))
    |> str_of_f_and_l
    |> Int.of_string
    |> ( + ) acc)
  |> Int.to_string
;;
