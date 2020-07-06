library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SEG7_LUT_8 is
	port(
		iDIG: in std_logic_vector(31 downto 0);
		oSEG0, oSEG1, oSEG2, oSEG3, oSEG4, oSEG5, oSEG6, oSEG7: out std_logic_vector(6 downto 0)
	);
end SEG7_LUT_8;

architecture SEG7_LUT_8_arch of SEG7_LUT_8 is
	
	component SEG7_LUT is
		port(
			iDIG: in std_logic_vector(3 downto 0);
			oSEG: out std_logic_vector(6 downto 0)
		);
	end component;
	
begin
	
	u0: SEG7_LUT port map(iDIG(3 downto 0), oSEG0);
	u1: SEG7_LUT port map(iDIG(7 downto 4), oSEG1);
	u2: SEG7_LUT port map(iDIG(11 downto 8), oSEG2);
	u3: SEG7_LUT port map(iDIG(15 downto 12), oSEG3);
	u4: SEG7_LUT port map(iDIG(19 downto 16), oSEG4);
	u5: SEG7_LUT port map(iDIG(23 downto 20), oSEG5);
	u6: SEG7_LUT port map(iDIG(27 downto 24), oSEG6);
	u7: SEG7_LUT port map(iDIG(31 downto 28), oSEG7);
	
end SEG7_LUT_8_arch;

