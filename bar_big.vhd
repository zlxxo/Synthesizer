library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bar_big is
	port(
		x, y, org_x, org_y, line_x, line_y: in std_logic_vector(11 downto 0);
		bar_space: out std_logic
	);
end bar_big;

architecture bar_big_arch of bar_big is

	signal x1, y1, org_x1, org_y1, line_x1, line_y1: unsigned(11 downto 0);
	
begin
	
	x1 <= unsigned(x);
	y1 <= unsigned(y);
	org_x1 <= unsigned(org_x);
	org_y1 <= unsigned(org_y);
	line_x1 <= unsigned(line_x);
	line_y1 <= unsigned(line_y);
	bar_space <= '0' when x1 < org_x1 or x1 > org_x1 + line_x1 or y1 < org_y1 or y1 > org_y1 + line_y1 else '1';
	
end bar_big_arch;