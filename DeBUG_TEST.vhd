library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DeBUG_TEST is
	port(
		iCLK, iRST_N, isound_off1, isound_off2: in std_logic;
		oSin_CLK: out std_logic
	);
end DeBUG_TEST;

architecture DeBUG_TEST_arch of DeBUG_TEST is
	
	signal cont_reg, cont_next: unsigned(31 downto 0);
	signal cont: std_logic_vector(31 downto 0);
	signal sound_off1_reg, sound_off1_next,
	sound_off2_reg, sound_off2_next: std_logic;
	
begin
	
	process(iCLK, iRST_N)
	begin
		if(iRST_N = '0') then
			cont_reg <= (others => '0');
			sound_off1_reg <= '0';
			sound_off2_reg <= '0';
		elsif(iCLK'event and iCLK = '1') then
			cont_reg <= cont_next;
			sound_off1_reg <= sound_off1_next;
			sound_off2_reg <= sound_off2_next;
		end if;
	end process;
	
	cont_next <= cont_reg + 1;
	sound_off1_next <= isound_off1;
	sound_off2_next <= isound_off2;
	
	cont <= std_logic_vector(cont_reg);
	oSin_CLK <= cont(4);
	
end DeBUG_TEST_arch;