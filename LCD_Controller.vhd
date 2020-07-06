library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_Controller is
	port(
		iDATA: in std_logic_vector(7 downto 0);
		iRS, iStart, iCLK, iRST_N: in std_logic;
		oDone: out std_logic;
		LCD_DATA: out std_logic_vector(7 downto 0);
		LCD_EN, LCD_RW, LCD_RS: out std_logic
	);
end LCD_Controller;

architecture LCD_Controller_arch of LCD_Controller is
	
	constant CLK_Divide: integer := 16;
	signal cont_reg,  cont_next: unsigned(4 downto 0);
	signal state_reg, state_next: unsigned(1 downto 0);
	signal oDone_reg, oDone_next, LCD_EN_reg, LCD_EN_next: std_logic;
	signal preStart_reg, preStart_next, mStart_reg, mStart_next: std_logic;
	
begin
	
	-- Only write to LCD, bypass iRS to LCD_RS
	LCD_DATA <= iDATA;
	LCD_RW <= '0';
	LCD_RS <= iRS;
	
	process(iCLK, iRST_N)
	begin
		if(iRST_N = '0') then
			oDone_reg <= '0';
			LCD_EN_reg <= '0';
			preStart_reg <= '0';
			mStart_reg <= '0';
			cont_reg <= (others => '0');
			state_reg <= (others => '0');
		elsif(iCLK'event and iCLK = '1') then
			oDone_reg <= oDone_next;
			LCD_EN_reg <= LCD_EN_next;
			preStart_reg <= preStart_next;
			mStart_reg <= mStart_next;
			cont_reg <= cont_next;
			state_reg <= state_next;
		end if;
	end process;
	
	preStart_next <= iStart;
	
	
	process(oDone_reg, LCD_EN_reg, preStart_reg, mStart_reg, cont_reg, state_reg, cont_reg)
		variable od, le, ms: std_logic;
		variable st: unsigned(1 downto 0);
		variable c: unsigned(4 downto 0);
	begin
		od := oDone_reg;
		le := LCD_EN_reg;
		ms := mStart_reg;
		st := state_reg;
		c := cont_reg;
		
		if(preStart_reg = '0' and iStart = '1') then
			ms := '1';
			od := '0';
		end if;
		
		if(mStart_reg = '1') then
			case state_reg is
				when to_unsigned(0, 2) =>
					st := state_reg + 1;
				when to_unsigned(1, 2) =>
					le := '1';
					st := state_reg + 1;
				when to_unsigned(2, 2) =>
					if(cont_reg < CLK_Divide) then
						c := cont_reg + 1;
					else
						st := state_reg + 1;
					end if;
				when to_unsigned(3, 2) =>
					le := '0';
					ms := '0';
					od := '0';
					c := (others => '0');
					st := (others => '0');
			end case;
		end if;
		
		oDone_next <= od;
		LCD_EN_next <= le;
		mStart_next <= ms;
		state_next <= st;
		cont_next <= c;
	end process;
	
	oDone <= oDOne_reg;
	LCD_EN <= LCD_EN_reg;
	
end LCD_Controller_arch;