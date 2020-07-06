library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bar_blank is
	port(
		CounterY: in std_logic_vector(11 downto 0);
		Hu4, Hu2, Hu1, Mu6, Mu5, Mu4,
		Mu2, Mu1, Lu6, Lu5, Lu4: out std_logic
	);
end bar_blank;

architecture bar_blank_arch of bar_blank is

	constant ydeta: integer := 30;
	constant yd_t: integer := ydeta + 2;
	constant yd_t0: integer := 15;
	constant yd_t1: integer := 15 + yd_t;
	constant yd_t2: integer := 15 + yd_t*2;
	constant yd_t3: integer := 15 + yd_t*3;
	constant yd_t4: integer := 15 + yd_t*4;
	constant yd_t5: integer := 15 + yd_t*5;
	constant yd_t6: integer := 15 + yd_t*6;
	constant yd_t7: integer := 15 + yd_t*7;
	constant yd_t8: integer := 15 + yd_t*8;
	constant yd_t9: integer := 15 + yd_t*9;
	constant yd_t10: integer := 15 + yd_t*10;
	constant yd_t11: integer := 15 + yd_t*11;
	constant yd_t12: integer := 15 + yd_t*12;
	constant yd_t13: integer := 15 + yd_t*13;
	constant yd_t14: integer := 15 + yd_t*14;
	constant yd_t15: integer := 15 + yd_t*15;
	signal cy: unsigned(11 downto 0);

begin
	
	cy <= unsigned(CounterY);
	Hu4 <= '0' when cy < yd_t0 or cy > yd_t1 else '1';
	Hu2 <= '0' when cy < yd_t2 or cy > yd_t3 else '1';
	Hu1 <= '0' when cy < yd_t3 or cy > yd_t4 else '1';
	Mu6 <= '0' when cy < yd_t5 or cy > yd_t6 else '1';
	Mu5 <= '0' when cy < yd_t6 or cy > yd_t7 else '1';
	Mu4 <= '0' when cy < yd_t7 or cy > yd_t8 else '1';
	Mu2 <= '0' when cy < yd_t9 or cy > yd_t10 else '1';
	Mu1 <= '0' when cy < yd_t10 or cy > yd_t11 else '1';
	Lu6 <= '0' when cy < yd_t12 or cy > yd_t13 else '1';
	Lu5 <= '0' when cy < yd_t13 or cy > yd_t14 else '1';
	Lu4 <= '0' when cy < yd_t14 or cy > yd_t15 else '1';
	
end bar_blank_arch;