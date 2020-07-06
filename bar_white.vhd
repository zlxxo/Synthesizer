library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bar_white is
	port(
		CounterY: in std_logic_vector(11 downto 0);
		L_5, L_6, L_7, M_1, M_2, M_3, M_4, M_5, M_6,
		M_7, H_1, H_2, H_3, H_4, H_5: out std_logic
	);
end bar_white;

architecture bar_white_arch of bar_white is

	constant ydeta: integer := 30;
	constant yd_t: integer := ydeta + 2;
	constant yd_t0: integer := 0;
	constant yd_t1: integer := yd_t;
	constant yd_t2: integer := yd_t*2;
	constant yd_t3: integer := yd_t*3;
	constant yd_t4: integer := yd_t*4;
	constant yd_t5: integer := yd_t*5;
	constant yd_t6: integer := yd_t*6;
	constant yd_t7: integer := yd_t*7;
	constant yd_t8: integer := yd_t*8;
	constant yd_t9: integer := yd_t*9;
	constant yd_t10: integer := yd_t*10;
	constant yd_t11: integer := yd_t*11;
	constant yd_t12: integer := yd_t*12;
	constant yd_t13: integer := yd_t*13;
	constant yd_t14: integer := yd_t*14;
	constant yd_t15: integer := yd_t*15;
	signal cy: unsigned(11 downto 0);

begin
	
	cy <= unsigned(CounterY);
	H_5 <= '0' when cy < yd_t0 or cy > yd_t1 else '1';
	H_4 <= '0' when cy < yd_t1 or cy > yd_t2 else '1';
	H_3 <= '0' when cy < yd_t2 or cy > yd_t3 else '1';
	H_2 <= '0' when cy < yd_t3 or cy > yd_t4 else '1';
	H_1 <= '0' when cy < yd_t4 or cy > yd_t5 else '1';
	M_7 <= '0' when cy < yd_t5 or cy > yd_t6 else '1';
	M_6 <= '0' when cy < yd_t6 or cy > yd_t7 else '1';
	M_5 <= '0' when cy < yd_t7 or cy > yd_t8 else '1';
	M_4 <= '0' when cy < yd_t8 or cy > yd_t9 else '1';
	M_3 <= '0' when cy < yd_t9 or cy > yd_t10 else '1';
	M_2 <= '0' when cy < yd_t10 or cy > yd_t11 else '1';
	M_1 <= '0' when cy < yd_t11 or cy > yd_t12 else '1';
	L_7 <= '0' when cy < yd_t12 or cy > yd_t13 else '1';
	L_6 <= '0' when cy < yd_t13 or cy > yd_t14 else '1';
	L_5 <= '0' when cy < yd_t14 or cy > yd_t15 else '1';
	
end bar_white_arch;