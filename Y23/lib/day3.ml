open Core
open Utils

(* let lines = lines_of_file "./inputs/test" *)
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

module TupSet = Set.Make (struct
    type t = int * int [@@deriving sexp, compare]
  end)

(* PERF: Implement list version and compare performances *)
let second =
  let directions = [ 1, 0; 1, 1; 1, -1; -1, 0; -1, 1; -1, -1; 0, 1; 0, -1 ] in
  let lines = List.to_array lines in
  let rec get_fst_ind a = function
    | b when b >= 0 && Char.is_digit lines.(a).[b] -> get_fst_ind a (b - 1)
    | b -> b + 1
  in
  let parse_num_at a b =
    let st = get_fst_ind a b in
    let num = ref 0 in
    let terminated = ref false in
    for i = st to String.length (Array.nget lines a) - 1 do
      if Char.is_digit lines.(a).[i] && not !terminated
      then num := (!num * 10) + Char.to_int lines.(a).[i] - Char.to_int '0'
      else terminated := true
    done;
    !num
  in
  lines
  |> Array.foldi ~init:0 ~f:(fun i arr_acc line ->
    String.foldi ~init:0 line ~f:(fun j str_acc ->
      function
      | ch when not @@ phys_equal ch '*' -> str_acc
      | _ ->
        directions
        |> List.fold ~init:TupSet.empty ~f:(fun acc (x, y) ->
          match i + x, j + y with
          | a, _ when a < 0 || a >= Array.length lines -> acc
          | _, b when b < 0 || b >= String.length line -> acc
          | a, b ->
            (match Char.is_digit lines.(a).[b] with
             | true -> Set.add acc (a, b)
             | _ -> acc))
        |> Set.fold ~init:TupSet.empty ~f:(fun acc (a, b) ->
          Set.add acc (a, get_fst_ind a b))
        |> (fun set ->
             match set with
             | set when Set.length set = 2 ->
               Set.fold set ~init:1 ~f:(fun acc (a, b) -> acc * parse_num_at a b)
             | _ -> 0)
        |> ( + ) str_acc)
    |> ( + ) arr_acc)
;;
