open Core

let ( >>@ ) t f = List.map t ~f
let ( >>| ) t f = List.filter t ~f
let ( >>|@ ) t f = List.filter_map t ~f
let ( >>~ ) t f = List.filter_map t ~f
let ( >>? ) t f = List.find_map t ~f
let ( >>. ) init f = List.fold ~init ~f
let ( >>$ ) f init = List.fold ~init ~f
let ( #> ) hof f = hof ~f
let ( |.. ) st en = List.range st en
let ( #~> ) str on = String.split ~on str
let ( #~ ) on str = String.split ~on str
let ( ~!:: ) li = List.last_exn li
let ( !:: ) li = List.hd_exn li
let ( ~// ) str = String.strip str
let ( !::* ) li = List.hd_exn li, List.last_exn li
let ( #?! ) def opt = Option.value opt ~default:def
let ( |@| ) f (fst, scn) = fst, f scn
let ( @|| ) f (fst, scn) = f fst, scn
let ( ||@ ) f (fst, scn) = f fst scn
let ( *|| ) f (fst, scn) = f fst, f scn
let ( *||| ) f (fst, scn, thr) = f fst, f scn, f thr
let ( |-| ) f (a, b) (a', b') = f a a', f b b'
let ( |-|| ) f (a, b, c) (a', b', c') = f a a', f b b', f c c'
let ( !+ ) str = Int.of_string str
let str_of_f_and_l li = Fmt.str "%s%s" (List.hd_exn li) (List.last_exn li)

let lines_of_file file =
  (Stdio.In_channel.with_file file)
  #> (fun ch ->
  let x = In_channel.input_all ch in
  String.split_lines x)
;;
