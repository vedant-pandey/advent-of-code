open Core
open Utils

(* let lines = lines_of_file "./inputs/test" *)
let lines = lines_of_file "./inputs/day4"

module IntSet = Set.Make (Int)

module IntMap = Map.Make (struct
    type t = int [@@deriving sexp, compare]
  end)

let first =
  lines
  |> List.foldi ~init:0 ~f:(fun _i top_acc line ->
    String.split ~on:':' line
    |> List.tl_exn
    |> List.hd_exn
    |> String.split ~on:'|'
    |> List.map ~f:(fun str ->
      str
      |> String.split ~on:' '
      |> List.filter ~f:(fun value -> String.length value > 0)
      |> List.map ~f:Int.of_string
      |> List.fold ~init:IntSet.empty ~f:(fun acc num -> Core.Set.add acc num))
    |> List.foldi ~init:IntSet.empty ~f:(fun ind acc cur_set ->
      match ind with
      | 0 -> cur_set
      | _ -> Core.Set.inter acc cur_set)
    |> Core.Set.length
    |> Int.pred
    |> (fun x ->
         match x with
         | x when x < 0 -> 0
         | x -> Int.pow 2 x)
    |> ( + ) top_acc)
;;

type rep_win =
  { win : int
  ; rep : int
  }
[@@deriving sexp]

let new_rep_win () = { win = 0; rep = 1 }

let second =
  let get_num_set str =
    str
    |> String.split ~on:' '
    |> List.filter ~f:(fun value -> String.length value > 0)
    |> List.map ~f:Int.of_string
    |> List.fold ~init:IntSet.empty ~f:Set.add
  in
  let inter_of_sets ind acc cur_set =
    match ind with
    | 0 -> cur_set
    | _ -> Set.inter acc cur_set
  in
  let win_rep_map =
    lines
    |> List.foldi ~init:IntMap.empty ~f:(fun i top_acc line ->
      let matches =
        line
        |> String.split ~on:':'
        |> List.tl_exn
        |> List.hd_exn
        |> String.split ~on:'|'
        |> List.map ~f:get_num_set
        |> List.foldi ~init:IntSet.empty ~f:inter_of_sets
        |> Set.length
      in
      Map.set top_acc ~key:i ~data:{ (new_rep_win ()) with win = matches })
  in
  win_rep_map
  |> Map.fold ~init:win_rep_map ~f:(fun ~key ~data:_ acc ->
    let data = Map.find acc key |> Option.value_exn in
    List.range (key + 1) (key + data.win + 1)
    |> List.fold ~init:acc ~f:(fun cur_acc cur_key ->
      Map.update cur_acc cur_key ~f:(fun cur_key_val_opt ->
        match cur_key_val_opt with
        | Some x -> { win = x.win; rep = x.rep + data.rep }
        | None -> new_rep_win ())))
  |> Map.fold ~init:0 ~f:(fun ~key:_ ~data acc -> acc + data.rep)
;;
