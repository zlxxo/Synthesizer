library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_TEST is
	port(
		iCLK,iRST_N: in std_logic;
		LCD_DATA: out std_logic_vector(7 downto 0);
		LCD_RW,LCD_EN,LCD_RS: out std_logic
	);
end LCD_TEST;

architecture LCD_TEST_arch of LCD_TEST is
	
	component LCD_Controller is
		port(
			iDATA: in std_logic_vector(7 downto 0);
			iRS, iStart, iCLK, iRST_N: in std_logic;
			oDone: out std_logic;
			LCD_DATA: out std_logic_vector(7 downto 0);
			LCD_EN, LCD_RW, LCD_RS: out std_logic
		);
	end component;
	
	constant	LCD_INTIAL: integer := 0;
	constant	LCD_LINE1: integer := 5;
	constant	LCD_CH_LINE: integer := LCD_LINE1+16;
	constant	LCD_LINE2: integer := LCD_LINE1+16+1;
	constant	LUT_SIZE: integer := LCD_LINE1+32+1;
	
	signal lut_index_reg, lut_index_next: integer := 0;
	signal LUT_DATA: std_logic_vector(8 downto 0);
	signal mlcd_state_reg, mlcd_state_next: unsigned(1 downto 0);
	signal mdly_reg, mdly_next: unsigned(17 downto 0);
	signal mlcd_start_reg, mlcd_start_next: std_logic;
	signal mlcd_data_reg, mlcd_data_next: std_logic_vector(7 downto 0);
	signal mlcd_rs_reg, mlcd_rs_next: std_logic;
	signal mlcd_done: std_logic;
	
begin
	
	process(iCLK, iRST_N)
	begin
		if(iRST_N = '0') then
			lut_index_reg <= 0;
			mlcd_state_reg <= (others => '0');
			mdly_reg <= (others => '0');
			mlcd_start_reg <= '0';
			mlcd_data_reg <= "00000000";
			mlcd_rs_reg <= '0';
		elsif(iCLK'event and iCLK = '1') then
			lut_index_reg <= lut_index_next;
			mlcd_state_reg <= mlcd_state_next;
			mdly_reg <= mdly_next;
			mlcd_start_reg <= mlcd_start_next;
			mlcd_data_reg <= mlcd_data_next;
			mlcd_rs_reg <= mlcd_rs_next;
		end if;
	end process;
	
	process(lut_index_reg, mlcd_state_reg, mdly_reg, mlcd_start_reg, mlcd_data_reg, mlcd_rs_reg)
		variable dat: std_logic_vector(7 downto 0);
		variable rs, start: std_logic;
		variable state: unsigned(1 downto 0);
		variable index: integer;
		variable dly: unsigned(17 downto 0);
	begin
		dat := mlcd_data_reg;
		rs := mlcd_rs_reg;
		start := mlcd_start_reg;
		state := mlcd_state_reg;
		index := lut_index_reg;
		dly := mdly_reg;
		
		if(lut_index_reg < LUT_SIZE) then
			case mlcd_state_reg is
				when to_unsigned(0, 2) =>
					dat := LUT_DATA(7 downto 0);
					rs := LUT_DATA(8);
					start := '1';
					state := mlcd_state_reg + 1;
				when to_unsigned(1, 2) =>
					if(mlcd_done = '1') then
						start := '0';
						state := mlcd_state_reg + 1;
					end if;
				when to_unsigned(2, 2) =>
					if(mdly_reg < 16#3FFFE#) then
						dly := mdly_reg + 1;
					else
						dly := (others => '0');
						state := mlcd_state_reg + 1;
					end if;
				when to_unsigned(3, 2) =>
					index := 0;
					state := (others => '0');
			end case;
		end if;
		
		mlcd_data_next <= dat;
		mlcd_rs_next <= rs;
		mlcd_start_next <= start;
		mlcd_state_next <= state;
		lut_index_next <= index;
		mdly_next <= dly;
	end process;
	
	LUT_DATA <= std_logic_vector(to_unsigned(16#038#, 9)) when lut_index_reg = LCD_INTIAL else
					std_logic_vector(to_unsigned(16#00C#, 9)) when lut_index_reg = LCD_INTIAL + 1 else
					std_logic_vector(to_unsigned(16#001#, 9)) when lut_index_reg = LCD_INTIAL + 2 else
					std_logic_vector(to_unsigned(16#006#, 9)) when lut_index_reg = LCD_INTIAL + 3 else
					std_logic_vector(to_unsigned(16#080#, 9)) when lut_index_reg = LCD_INTIAL + 4 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 1 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 2 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 3 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 4 else
					std_logic_vector(to_unsigned(16#144#, 9)) when lut_index_reg = LCD_LINE1 + 5 else -- D
					std_logic_vector(to_unsigned(16#145#, 9)) when lut_index_reg = LCD_LINE1 + 6 else -- E
					std_logic_vector(to_unsigned(16#132#, 9)) when lut_index_reg = LCD_LINE1 + 7 else -- 2
					std_logic_vector(to_unsigned(16#1b0#, 9)) when lut_index_reg = LCD_LINE1 + 8 else -- -
					std_logic_vector(to_unsigned(16#137#, 9)) when lut_index_reg = LCD_LINE1 + 9 else -- 7
					std_logic_vector(to_unsigned(16#130#, 9)) when lut_index_reg = LCD_LINE1 + 10 else -- 0
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 11 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 12 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 13 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 14 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE1 + 15 else
					std_logic_vector(to_unsigned(16#0C0#, 9)) when lut_index_reg = LCD_CH_LINE else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE2 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE2 + 1 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE2 + 2 else
					std_logic_vector(to_unsigned(16#153#, 9)) when lut_index_reg = LCD_LINE2 + 3 else -- S
					std_logic_vector(to_unsigned(16#179#, 9)) when lut_index_reg = LCD_LINE2 + 4 else -- y
					std_logic_vector(to_unsigned(16#16E#, 9)) when lut_index_reg = LCD_LINE2 + 5 else -- n
					std_logic_vector(to_unsigned(16#174#, 9)) when lut_index_reg = LCD_LINE2 + 6 else -- t
					std_logic_vector(to_unsigned(16#168#, 9)) when lut_index_reg = LCD_LINE2 + 7 else -- h
					std_logic_vector(to_unsigned(16#165#, 9)) when lut_index_reg = LCD_LINE2 + 8 else -- e
					std_logic_vector(to_unsigned(16#173#, 9)) when lut_index_reg = LCD_LINE2 + 9 else -- s
					std_logic_vector(to_unsigned(16#169#, 9)) when lut_index_reg = LCD_LINE2 + 10 else -- i
					std_logic_vector(to_unsigned(16#17A#, 9)) when lut_index_reg = LCD_LINE2 + 11 else -- z
					std_logic_vector(to_unsigned(16#165#, 9)) when lut_index_reg = LCD_LINE2 + 12 else -- e
					std_logic_vector(to_unsigned(16#172#, 9)) when lut_index_reg = LCD_LINE2 + 13 else -- r
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE2 + 14 else
					std_logic_vector(to_unsigned(16#120#, 9)) when lut_index_reg = LCD_LINE2 + 15 else
					std_logic_vector(to_unsigned(0, 9));
	
	u0: LCD_Controller port map(mlcd_data_reg, mlcd_rs_reg, mlcd_start_reg, iCLK, iRST_N,
	mlcd_done, LCD_DATA, LCD_EN, LCD_RW, LCD_RS);

end LCD_TEST_arch;