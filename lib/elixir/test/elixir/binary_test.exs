Code.require_file "../test_helper.exs", __FILE__

defmodule Binary.LiteralTest do
  use ExUnit.Case, async: true

  test :heredoc do
    assert 7 == __ENV__.line
    assert "foo\nbar\n" == """
foo
bar
"""

    assert 13 == __ENV__.line
    assert "foo\nbar \"\"\"\n" == """
foo
bar """
"""
  end

  test :heredoc_with_extra do
    assert 21 == __ENV__.line
    assert "foo\nbar\nbar\n" == """ <> "bar\n"
foo
bar
"""
  end

  test :aligned_heredoc do
    assert "foo\nbar\nbar\n" == """ <> "bar\n"
    foo
    bar
    """
  end

  test :utf8 do
    assert size(" ゆんゆん") == 13
  end

  test :utf8_char do
    assert ?ゆ == 12422
    assert ?\ゆ == 12422
  end

  test :string_concatenation_as_match do
    "foo" <> x = "foobar"
    assert x == "bar"
  end

  test :octals do
    assert "\o1" == <<1>>
    assert "\o12" == "\n"
    assert "\o123" == "S"
    assert "\O123" == "S"
    assert "\o377" == "ÿ"
    assert "\o128" == "\n8"
    assert "\o18"  == <<1,?8>>
  end

  test :hex do
    assert "\xa" == "\n"
    assert "\xE9" == "é"
    assert "\xFF" == "ÿ"
    assert "\x{A}"== "\n"
    assert "\x{E9}"== "é"
    assert "\x{10F}" == <<196,143>>
    assert "\x{10FF}" == <<225,131,191>>
    assert "\x{10FFF}" == <<240,144,191,191>>
    assert "\x{10FFFF}" == <<244,143,191,191>>
  end

  test :match do
    assert is_match?("ab", ?a)
    assert not is_match?("cd", ?a)
  end

  test :pattern_match do
    s = 16
    assert <<_a, _b :: size(s)>> = "foo"
  end

  test :partial_application do
    assert (<< &1, 2 >>).(1) == << 1, 2 >>
    assert (<< &1, &2 >>).(1, 2) == << 1, 2 >>
    assert (<< &2, &1 >>).(2, 1) == << 1, 2 >>
  end

  test :bitsyntax_with_utf do
    assert <<106,111,115,101>> == << "jose" :: utf8 >>
    assert <<106,111,115,101>> == << 'jose' :: utf8 >>

    assert <<0,106,0,111,0,115,0,101>> == << "jose" :: utf16 >>
    assert <<0,106,0,111,0,115,0,101>> == << 'jose' :: utf16 >>

    assert <<106,0,111,0,115,0,101,0>> == << "jose" :: [utf16, little] >>
    assert <<106,0,111,0,115,0,101,0>> == << 'jose' :: [utf16, little] >>

    assert <<0,0,0,106,0,0,0,111,0,0,0,115,0,0,0,101>> == << "jose" :: utf32 >>
    assert <<0,0,0,106,0,0,0,111,0,0,0,115,0,0,0,101>> == << 'jose' :: utf32 >>
  end

  test :bitsyntax_translation do
    refb = "sample"
    sec_data = "another"
    << size(refb) :: [size(1), big, signed, integer, unit(8)],
       refb :: binary,
       size(sec_data) :: [size(1), big, signed, integer, unit(16)],
       sec_data :: binary >>
  end

  defmacrop signed_16 do
    quote do
      [big, signed, integer, unit(16)]
    end
  end

  defmacrop refb_spec do
    quote do
      [size(1), big, signed, integer, unit(8)]
    end
  end

  test :bitsyntax_macro do
    refb = "sample"
    sec_data = "another"
    << size(refb) :: refb_spec,
       refb :: binary,
       size(sec_data) :: [size(1) | signed_16],
       sec_data :: binary >>
  end

  defp is_match?(<<char, _ :: binary>>, char) do
    true
  end

  defp is_match?(_, _) do
    false
  end
end