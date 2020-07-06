library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_gen_brass is
	port(
		ramp: in std_logic_vector(5 downto 0);
		music_o: out std_logic_vector(15 downto 0)
	);
end wave_gen_brass;

architecture wave_gen_brass_arch of wave_gen_brass is
	
	signal r: integer;
	signal m: integer;
	
begin
	
	r <= to_integer(unsigned(ramp));
	
	with r select
		m <= 16#366# when 7,
			  16#782# when 8,
			  16#C60# when 9,
			  16#1208# when 10,
			  16#183A# when 11,
			  16#1E44# when 12,
			  16#23EB# when 13,
			  16#299B# when 14,
			  16#2EDE# when 15,
			  16#3339# when 16,
			  16#36B0# when 17,
			  16#38CC# when 18,
			  16#38FD# when 19,
			  16#3766# when 20,
			  16#34AA# when 21,
			  16#30FA# when 22,
			  16#2C38# when 23,
			  16#2697# when 24,
			  16#2056# when 25,
			  16#1984# when 26,
			  16#1224# when 27,
			  16#A8A# when 28,
			  16#385# when 29,
			  16#FFFFFDA8# when 30,
			  16#FFFFF8E0# when 31,
			  16#FFFFF4F2# when 32,
			  16#FFFFF192# when 33,
			  16#FFFFEE42# when 34,
			  16#FFFFEB00# when 35,
			  16#FFFFE84A# when 36,
			  16#FFFFE650# when 37,
			  16#FFFFE50C# when 38,
			  16#FFFFE496# when 39,
			  16#FFFFE48C# when 40,
			  16#FFFFE47C# when 41,
			  16#FFFFE465# when 42,
			  16#FFFFE412# when 43,
			  16#FFFFE361# when 44,
			  16#FFFFE2CC# when 45,
			  16#FFFFE2BC# when 46,
			  16#FFFFE31C# when 47,
			  16#FFFFE3E9# when 48,
			  16#FFFFE515# when 49,
			  16#FFFFE678# when 50,
			  16#FFFFE7D8# when 51,
			  16#FFFFE91B# when 52,
			  16#FFFFEA5E# when 53,
			  16#FFFFEBC1# when 54,
			  16#FFFFED67# when 55,
			  16#FFFFEF6D# when 56,
			  16#FFFFF1FA# when 57,
			  16#FFFFF4F2# when 58,
			  16#FFFFF7D9# when 59,
			  16#FFFFFA78# when 60,
			  16#FFFFFCD7# when 61,
			  16#FFFFFEF7# when 62,
			  16#DA# when 63,
			  0 when others;
	
	music_o <= std_logic_vector(to_unsigned(m, 16));
	
end wave_gen_brass_arch;