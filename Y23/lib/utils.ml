open Core

let ( =>@ ) t f = Array.map t ~f
let ( =>@+ ) t f = Array.mapi t ~f
let ( =>. ) init f = Array.fold ~init ~f
let ( =>| ) t f = Array.filter t ~f
let ( =>|+ ) t f = Array.filteri t ~f
let ( =>|@ ) t f = Array.filter_map t ~f
let ( =>|@+ ) t f = Array.filter_mapi t ~f
let ( =>> ) t f = Array.iter t ~f
let ( =>>+ ) t f = Array.iteri t ~f
let ( >>@ ) t f = List.map t ~f
let ( >>| ) t f = List.filter t ~f
let ( >>|@ ) t f = List.filter_map t ~f
let ( >>?@ ) t f = List.find_map t ~f
let ( >>. ) init f = List.fold ~init ~f
let ( >>> ) t f = List.iter t ~f
let ( >>>+ ) t f = List.iteri t ~f
let ( #> ) hof f = hof ~f
let ( |.. ) st en = List.range st en
let ( #~> ) str on = String.split ~on str
let ( #~ ) on str = String.split ~on str
let ( ~// ) str = String.strip str
let ( !:: ) li = List.hd_exn li
let ( !*:: ) li = List.tl_exn li
let ( !!:: ) li = List.hd_exn @@ List.tl_exn li
let ( ~!:: ) li = List.last_exn li
let ( !::~ ) li = List.hd_exn li, List.last_exn li
let ( #?! ) def opt = Option.value opt ~default:def
let ( |@| ) f (fst, scn) = fst, f scn
let ( @|| ) f (fst, scn) = f fst, scn
let ( ||@ ) f (fst, scn) = f fst scn
let ( *|| ) f tup2 = Tuple2.map tup2 ~f
let ( *||| ) f tup3 = Tuple3.map tup3 ~f
let ( |-| ) f tup2 tup2' = Tuple2.map2 tup2 tup2' ~f
let ( |-|| ) f tup3 tup3' = Tuple3.map2 tup3 tup3' ~f
let ( !+ ) str = Int.of_string str
let ( !| ) tup = Tuple2.get1 tup
let ( !|| ) tup = Tuple2.get2 tup
let str_of_f_and_l li = Fmt.str "%s%s" (List.hd_exn li) (List.last_exn li)

let lines_of_file file =
  (Stdio.In_channel.with_file file)
  #> (fun ch ->
  let x = In_channel.input_all ch in
  String.split_lines x)
;;

let arr_rng arr i = i >= 0 && i < Array.length arr
let mat_rng mat i j = i >= 0 && i < Array.length mat && j >= 0 && j < Array.length mat.(i)
let arr_get arr i ~default = if arr_rng arr i then arr.(i) else default
let mat_get mat i j ~default = if mat_rng mat i j then mat.(i).(j) else default
