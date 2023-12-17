open Y23
open Core
open Utils

let () =
  [ "1a"; "1b"; "2a"; "2b"; "3a"; "3b" ]
  |> (()
      >>. fun _ -> function
            | "1a" -> Fmt.pr "@. 1a - %d" Day1.first
            | "1b" -> Fmt.pr "@. 1b - %d" Day1.second
            | "2a" -> Fmt.pr "@. 2a - %d" Day2.first
            | "2b" -> Fmt.pr "@. 2b - %d" Day2.second
            | "3a" -> Fmt.pr "@. 3a - %d" Day3.first
            | "3b" -> Fmt.pr "@. 3b - %d" Day3.second
            | _ -> print_endline "");
  Fmt.pr "@."
;;
