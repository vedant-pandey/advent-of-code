open Core
open Utils

let lines = lines_of_file "./inputs/day2"

let first =
  let reds = 12 in
  let blues = 14 in
  let greens = 13 in
  lines
  >>| (fun line ->
        ~!::(line #~> ':') #~> ';'
        >>@ (fun str ->
              str #~> ','
              >>@ ( ~// )
              >>@ ( #~ ) ' '
              >>@ ( !::* )
              >>@ ( |@| ) (function
                | "red" -> reds
                | "green" -> greens
                | "blue" -> blues
                | _ -> 0)
              >>@ ( @|| ) Int.of_string
              >>@ ( ||@ ) ( <= )
              |> (true >>. ( && )))
        |> (true >>. fun acc cur -> acc && cur))
  |> (0
      >>. fun acc line ->
      !::(line #~> ':')
      |> String.chop_prefix ~prefix:"Game "
      |> ( #?! ) "0"
      |> Int.of_string
      |> ( + ) acc)
  |> Int.to_string
;;

type cols =
  { red : int
  ; blue : int
  ; green : int
  }

let second =
  lines
  >>@ (fun line ->
        ~!::(line #~> ':') #~> ';'
        >>@ (fun str ->
              str #~> ','
              >>@ ( ~// )
              >>@ ( #~ ) ' '
              >>@ (fun cnt_col ->
                    match ~!::cnt_col with
                    | "red" -> { red = !+(!::cnt_col); blue = 0; green = 0 }
                    | "blue" -> { blue = !+(!::cnt_col); red = 0; green = 0 }
                    | "green" -> { green = !+(!::cnt_col); blue = 0; red = 0 }
                    | _ -> { red = 0; blue = 0; green = 0 })
              >>@ (fun { red; blue; green } -> red, blue, green)
              |> ((0, 0, 0) >>. fun acc value -> ( |-|| ) Int.max acc value))
        |> ((0, 0, 0) >>. fun acc value -> ( |-|| ) Int.max acc value)
        |> fun (a, b, c) -> a * b * c)
  |> (0 >>. fun acc value -> acc + value)
  |> Int.to_string
;;
