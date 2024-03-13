defmodule MorseCode.Main do
  alias MorseCode.MorseCode, as: MC

  def main() do
    IO.puts(MC.decode(MC.parse(MC.base()), MC.tree()))
    IO.puts(MC.decode(MC.parse(MC.rolled()), MC.tree()))

    IO.puts(
      MC.decode(
        MC.parse(
          ~c"----. ----. ..-- .-.. .. - - .-.. . ..-- -... ..- --. ... ..-- .. -. ..-- - .... . ..-- -.-. --- -.. . --..-- ..-- ----. ----. ..-- .-.. .. - - .-.. . ..-- -... ..- --. ... --..-- ..-- -.-- --- ..- ..-- - .- -.- . ..-- --- -. . ..-- -.. --- .-- -. ..-- .- -. -.. ..-- .--. .- - -.-. .... ..-- .. - ..-- .- .-. --- ..- -. -.. --..-- ..-- .---- ..--- ..... ..-- .-.. .. - - .-.. . ..-- -... ..- --. ... ..-- .. -. ..-- - .... . ..-- -.-. --- -.. ."
        ),
        MC.tree()
      )
    )

    table = MC.encode_table(MC.tree())
    IO.inspect(table)
    encoded = MC.encode(~c"fuck this", table)
    IO.inspect(MC.parse(encoded))
    IO.inspect(encoded)
    IO.inspect(MC.decode(MC.parse(encoded), MC.tree()))
  end
end
