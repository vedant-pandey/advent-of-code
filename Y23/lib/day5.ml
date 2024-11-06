open Core
open Utils

let lines = lines_of_file "./inputs/test"
(* let lines = lines_of_file "./inputs/day5" *)

type st_en_rng =
  { st : int
  ; en : int
  ; rng : int
  }
[@@deriving sexp]

let new_st_en_rng () = { st = -1; en = -1; rng = -1 }

module StringMap = Map.Make (struct
    type t = string [@@deriving sexp, compare]
  end)

let first =
  let parse_map_line line : st_en_rng =
    line
    |> String.split ~on:' '
    |> List.filter ~f:(fun str -> not @@ String.is_empty str)
    |> List.map ~f:Int.of_string
    |> fun lst ->
    match lst with
    | [ st; en; rng ] -> { st; en; rng }
    | _ -> raise_s [%sexp "incorrect parse range line"]
  in
  let _, fin_map, seed_list =
    lines
    |> List.fold
         ~init:("", (StringMap.empty : st_en_rng list StringMap.t), [])
         ~f:(fun (cur_map, acc, seed_list) line ->
           match line with
           | "" -> cur_map, acc, seed_list
           | line ->
             (match line.[0] with
              | '0' .. '9' ->
                let acc =
                  Map.update acc cur_map ~f:(fun data_opt ->
                    Option.value ~default:[] data_opt |> List.cons @@ parse_map_line line)
                in
                cur_map, acc, seed_list
              | 'a' .. 'z' when Char.to_int line.[4] = Char.to_int 's' ->
                let seed_list =
                  line
                  |> String.split ~on:':'
                  |> List.tl_exn
                  |> List.hd_exn
                  |> String.split ~on:' '
                  |> List.filter ~f:(fun str -> not @@ String.is_empty str)
                  |> List.map ~f:Int.of_string
                in
                cur_map, acc, seed_list
              | 'a' .. 'z' ->
                let cur_map = String.drop_suffix line 5 in
                cur_map, acc, seed_list
              | _ -> raise_s [%sexp "Non alphanumeric found"]))
  in
  let locate_and_resolve { st; en; rng } (inp : int) : int option =
    match inp with
    | inp when en <= inp && inp < en + rng -> Some (inp - en + st)
    | _ -> None
  in
  let map_collapse seed =
    [ "seed-to-soil"
    ; "soil-to-fertilizer"
    ; "fertilizer-to-water"
    ; "water-to-light"
    ; "light-to-temperature"
    ; "temperature-to-humidity"
    ; "humidity-to-location"
    ]
    |> List.fold ~init:seed ~f:(fun acc map_name ->
      map_name
      |> Map.find_exn fin_map
      |> List.find_map ~f:(fun ser -> locate_and_resolve ser acc)
      |> Option.value ~default:acc)
  in
  seed_list
  |> List.map ~f:map_collapse
  |> List.reduce ~f:(fun acc elt -> Int.min acc elt)
  |> Option.value_exn
;;

type seed_tuple =
  { seed_st : int
  ; seed_en : int
  }
[@@deriving sexp, compare]

type seed_resolved_and_partial =
  { resolved : seed_tuple list
  ; left : seed_tuple
  }
[@@deriving sexp, compare]

let second =
  let parse_map_line line =
    line
    |> String.split ~on:' '
    |> List.filter ~f:(fun str -> not @@ String.is_empty str)
    |> List.map ~f:Int.of_string
    |> fun lst ->
    match lst with
    | [ st; en; rng ] -> { st; en; rng }
    | _ -> raise_s [%sexp "incorrect parse range line"]
  in
  let rec reduce_seeds_rec ?(acc = []) = function
    | [] -> acc
    | a :: b :: tl -> reduce_seeds_rec ~acc:({ seed_st = a; seed_en = a + b } :: acc) tl
    | _ -> raise_s [%sexp "Non even number of seeds"]
  in
  let[@warning "-27"] _, fin_map, (seed_list : seed_tuple list) =
    lines
    |> List.fold
         ~init:("", (StringMap.empty : st_en_rng list StringMap.t), [])
         ~f:(fun (cur_map, acc, seed_list) line ->
           match line with
           | "" -> cur_map, acc, seed_list
           | line ->
             (match line.[0] with
              | '0' .. '9' ->
                let acc =
                  Map.update acc cur_map ~f:(fun data_opt ->
                    Option.value ~default:[] data_opt |> List.cons @@ parse_map_line line)
                in
                cur_map, acc, seed_list
              | 'a' .. 'z' when Char.to_int line.[4] = Char.to_int 's' ->
                let seed_list =
                  line
                  |> String.split ~on:':'
                  |> List.tl_exn
                  |> List.hd_exn
                  |> String.split ~on:' '
                  |> List.filter ~f:(fun str -> not @@ String.is_empty str)
                  |> List.map ~f:Int.of_string
                  |> reduce_seeds_rec
                in
                cur_map, acc, seed_list
              | 'a' .. 'z' ->
                let cur_map = String.drop_suffix line 5 in
                cur_map, acc, seed_list
              | _ -> raise_s [%sexp "Non alphanumeric found"]))
  in
  print_s [%sexp (seed_list : seed_tuple list)];
  let[@warning "-27"] tup_expand (seed_tup : seed_tuple) (range_map : st_en_rng list)
    : seed_tuple list
    =
    raise_s [%sexp "Not implemented seed expand"]
  in
  [ "seed-to-soil"
  ; "soil-to-fertilizer"
  ; "fertilizer-to-water"
  ; "water-to-light"
  ; "light-to-temperature"
  ; "temperature-to-humidity"
  ; "humidity-to-location"
  ]
  |> List.fold ~init:seed_list ~f:(fun acc map_name ->
    acc
    |> List.fold ~init:[] ~f:(fun inner_acc seed_tup ->
      Map.find_exn fin_map map_name |> tup_expand seed_tup |> List.append inner_acc))
  |> List.map ~f:(fun { seed_en; _ } -> seed_en)
  |> List.reduce_exn ~f:Int.min
;;
