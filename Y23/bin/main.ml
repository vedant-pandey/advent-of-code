open Y23
open Core
open Utils

let () =
  [ "1a"
  ; "1b"
  ; "2a"
  ; "2b"
  ; "3a"
  ; "3b"
  ; "4a"
  ; "4b"
  ; "5a"
  ; "5b"
    (* ; "6a" ; "6b" ; "7a" ; "7b" ; "8a" ; "8b" ; "9a" ; "9b" ; "10a" ; "10b" *)
    (* ; "11a" ; "11b" ; "12a" ; "12b" ; "13a" ; "13b" ; "14a" ; "14b" ; "15a" ; "15b" *)
    (* ; "16a" ; "16b" ; "17a" ; "17b" ; "18a" ; "18b" ; "19a" ; "19b" ; "20a" ; "20b" *)
    (* ; "21a" ; "21b" ; "22a" ; "22b" ; "23a" ; "23b" ; "24a" ; "24b" ; "25a" ; "25b" *)
  ]
  |> (()
      >>. fun _ -> function
            | "1a" -> Fmt.pr "@. 1a - %d" Day1.first
            | "1b" -> Fmt.pr "@. 1b - %d" Day1.second
            | "2a" -> Fmt.pr "@. 2a - %d" Day2.first
            | "2b" -> Fmt.pr "@. 2b - %d" Day2.second
            | "3a" -> Fmt.pr "@. 3a - %d" Day3.first
            | "3b" -> Fmt.pr "@. 3b - %d" Day3.second
            | "4a" -> Fmt.pr "@. 4a - %d" Day4.first
            | "4b" -> Fmt.pr "@. 4b - %d" Day4.second
            | "5a" -> Fmt.pr "@. 5a - %d" Day5.first
            | "5b" -> Fmt.pr "@. 5b - %d" Day5.second
            (* | "6a" -> Fmt.pr "@. 6a - %d" Day6.first *)
            (* | "6b" -> Fmt.pr "@. 6b - %d" Day6.second *)
            (* | "7a" -> Fmt.pr "@. 7a - %d" Day7.first *)
            (* | "7b" -> Fmt.pr "@. 7b - %d" Day7.second *)
            (* | "8a" -> Fmt.pr "@. 8a - %d" Day8.first *)
            (* | "8b" -> Fmt.pr "@. 8b - %d" Day8.second *)
            (* | "9a" -> Fmt.pr "@. 9a - %d" Day9.first *)
            (* | "9b" -> Fmt.pr "@. 9b - %d" Day9.second *)
            (* | "10a" -> Fmt.pr "@. 10a - %d" Day10.first *)
            (* | "10b" -> Fmt.pr "@. 10b - %d" Day10.second *)
            (* | "11a" -> Fmt.pr "@. 11a - %d" Day11.first *)
            (* | "11b" -> Fmt.pr "@. 11b - %d" Day11.second *)
            (* | "12a" -> Fmt.pr "@. 12a - %d" Day12.first *)
            (* | "12b" -> Fmt.pr "@. 12b - %d" Day12.second *)
            (* | "13a" -> Fmt.pr "@. 13a - %d" Day13.first *)
            (* | "13b" -> Fmt.pr "@. 13b - %d" Day13.second *)
            (* | "14a" -> Fmt.pr "@. 14a - %d" Day14.first *)
            (* | "14b" -> Fmt.pr "@. 14b - %d" Day14.second *)
            (* | "15a" -> Fmt.pr "@. 15a - %d" Day15.first *)
            (* | "15b" -> Fmt.pr "@. 15b - %d" Day15.second *)
            (* | "16a" -> Fmt.pr "@. 16a - %d" Day16.first *)
            (* | "16b" -> Fmt.pr "@. 16b - %d" Day16.second *)
            (* | "17a" -> Fmt.pr "@. 17a - %d" Day17.first *)
            (* | "17b" -> Fmt.pr "@. 17b - %d" Day17.second *)
            (* | "18a" -> Fmt.pr "@. 18a - %d" Day18.first *)
            (* | "18b" -> Fmt.pr "@. 18b - %d" Day18.second *)
            (* | "19a" -> Fmt.pr "@. 19a - %d" Day19.first *)
            (* | "19b" -> Fmt.pr "@. 19b - %d" Day19.second *)
            (* | "20a" -> Fmt.pr "@. 20a - %d" Day20.first *)
            (* | "20b" -> Fmt.pr "@. 20b - %d" Day20.second *)
            (* | "21a" -> Fmt.pr "@. 21a - %d" Day21.first *)
            (* | "21b" -> Fmt.pr "@. 21b - %d" Day21.second *)
            (* | "22a" -> Fmt.pr "@. 22a - %d" Day22.first *)
            (* | "22b" -> Fmt.pr "@. 22b - %d" Day22.second *)
            (* | "23a" -> Fmt.pr "@. 23a - %d" Day23.first *)
            (* | "23b" -> Fmt.pr "@. 23b - %d" Day23.second *)
            (* | "24a" -> Fmt.pr "@. 24a - %d" Day24.first *)
            (* | "24b" -> Fmt.pr "@. 24b - %d" Day24.second *)
            (* | "25a" -> Fmt.pr "@. 25a - %d" Day25.first *)
            (* | "25b" -> Fmt.pr "@. 25b - %d" Day25.second *)
            | _ -> ());
  Fmt.pr "@."
;;
