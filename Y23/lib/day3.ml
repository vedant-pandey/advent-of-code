open Core
open Utils

let lines = lines_of_file "./inputs/day3"

let first =
  let line_mat = lines |> List.to_array =>@ String.to_array in
  let collapse_surr i j =
    [ 0, 1; 0, -1; 1, 0; -1, 0; 1, 1; -1, -1; 1, -1; -1, 1 ]
    >>@ (fun (f, s) -> mat_get line_mat (i + f) (j + s) ~default:'.')
    |> (false
        >>. fun acc -> function
              | '0' .. '9' | '.' -> acc
              | _ -> true)
  in
  let to_str_bool (char_bool_arr : (char * bool) array) =
    char_bool_arr
    |> ([ "", false ]
        =>. fun acc (ch, bl) ->
        match ch with
        | '0' .. '9' ->
          let hd = !::acc in
          let new_str = String.append !|hd (String.of_char ch) in
          let new_yn = !||hd || bl in
          (new_str, new_yn) :: !*::acc
        | _ -> ("", false) :: acc)
  in
  line_mat
  =>@+ (fun i ch_arr ->
         ch_arr =>@+ fun j ch -> ch, (not @@ Char.is_digit ch) || collapse_surr i j)
  =>@ to_str_bool
  =>@ (fun k ->
        k
        >>|@ fun (str, bl) ->
        match bl with
        | true -> Some str
        | false -> None)
  =>@ (fun k -> k >>@ Int.of_string |> (0 >>. fun acc var -> acc + var))
  |> (0 =>. fun acc var -> acc + var)
;;

let second = List.length lines
