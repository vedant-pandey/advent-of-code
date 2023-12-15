open Y23
open Core

let () =
  [ "1a"; "1b" ]
  |> List.fold ~init:() ~f:(fun _ q ->
    match q with
    | "1a" -> Fmt.pr "@. 1a - %s" Day1.first
    | "1b" -> Fmt.pr "@. 1b - %s" Day1.second
    | _ -> ())
;;
