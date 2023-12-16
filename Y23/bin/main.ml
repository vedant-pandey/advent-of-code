open Y23
open Core
open Utils

let () =
  [ "1a"; "1b"; "2a"; "2b" ]
  |> (()
      >>. fun _ -> function
            | "1a" -> Fmt.pr "@. 1a - %s" Day1.first
            | "1b" -> Fmt.pr "@. 1b - %s" Day1.second
            | "2a" -> Fmt.pr "@. 2a - %s" Day2.first
            | "2b" -> Fmt.pr "@. 2b - %s" Day2.second
            | _ -> print_endline "");
  Fmt.pr "@."
;;
