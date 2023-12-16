open Core
open Utils

let lines = lines_of_file "./inputs/day1"

let first =
  lines
  |> (0
      >>. fun acc line ->
      line
      |> String.to_list
      >>| Char.is_digit
      >>@ String.of_char
      |> str_of_f_and_l
      |> Int.of_string
      |> ( + ) acc)
  |> Int.to_string
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
  lines
  |> (0
      >>. fun acc line ->
      0
      |.. String.length line
      >>~ (fun pos ->
            vals
            >>? fun (pattern, value) ->
            match String.substr_index ~pos line ~pattern with
            | Some match_pos when match_pos = pos -> Some value
            | _ -> None)
      |> str_of_f_and_l
      |> Int.of_string
      |> ( + ) acc)
  |> Int.to_string
;;
