library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_gen_string is
	port(
		ramp: in std_logic_vector(5 downto 0);
		music_o: out std_logic_vector(15 downto 0)
	);
end wave_gen_string;

architecture wave_gen_string_arch of wave_gen_string is
	
	signal r: integer;
	signal m: integer;
	
begin
	
	r <= to_integer(unsigned(ramp));
	
	with r select
		m <= 16#246# when 6,
			  16#C36# when 7,
			  16#CFC# when 8,
			  16#C17# when 9,
			  16#AEE# when 10,
			  16#AA0# when 11,
			  16#BB8# when 12,
			  16#BAE# when 13,
			  16#9E4# when 14,
			  16#834# when 15,
			  16#789# when 16,
			  16#A89# when 17,
			  16#115A# when 18,
			  16#19D4# when 19,
			  16#2316# when 20,
			  16#2825# when 21,
			  16#24BA# when 22,
			  16#1D2E# when 23,
			  16#143B# when 24,
			  16#E10# when 25,
			  16#1345# when 26,
			  16#1E4B# when 27,
			  16#2392# when 28,
			  16#1E0A# when 29,
			  16#F4A# when 30,
			  16#37F# when 31,
			  16#1E0# when 32,
			  16#560# when 33,
			  16#9B7# when 34,
			  16#F84# when 35,
			  16#16D8# when 36,
			  16#1B1D# when 37,
			  16#1B6C# when 38,
			  16#1B5D# when 39,
			  16#175E# when 40,
			  16#D34# when 41,
			  16#33A# when 42,
			  16#FFFFFCF5# when 43,
			  16#FFFFFAC0# when 44,
			  16#FFFFF9B0# when 45,
			  16#FFFFF3FE# when 46,
			  16#FFFFF103# when 47,
			  16#FFFFF394# when 48,
			  16#FFFFEBEE# when 49,
			  16#FFFFDD00# when 50,
			  16#FFFFD7D4# when 51,
			  16#FFFFE07A# when 52,
			  16#FFFFEA88# when 53,
			  16#FFFFE8BA# when 54,
			  16#FFFFE507# when 55,
			  16#FFFFE4C4# when 56,
			  16#FFFFE68E# when 57,
			  16#FFFFEBB8# when 58,
			  16#FFFFED46# when 59,
			  16#FFFFF2B2# when 60,
			  16#FFFFF899# when 61,
			  16#FFFFF4AF# when 62,
			  16#FFFFFAA7# when 63,
			  0 when others;
	
	music_o <= std_logic_vector(to_unsigned(m, 16));
	
end wave_gen_string_arch;