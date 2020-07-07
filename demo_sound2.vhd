library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_sound2 is
	port(
		clock, k_tr: in std_logic;
		key_code: out std_logic_vector(7 downto 0)
	);
end demo_sound2;

architecture demo_sound2_arch of demo_sound2 is
	
	signal tmp_reg, tmp_next: unsigned(15 downto 0) := (others => '0'); 
	signal tmpa: unsigned(15 downto 0);
	signal tr_reg, tr_next: std_logic;
	constant step_r: integer := 58;
	signal step_reg, step_next: integer;
	signal TT_un: unsigned(7 downto 0);
	signal TT: std_logic_vector(7 downto 0);
	signal st_reg, st_next: unsigned(5 downto 0) := (others => '0');
	signal go_end_reg, go_end_next: std_logic;
	signal key_code1: unsigned(7 downto 0);
	
begin
	
	-- register logic for music processing
	process(k_tr, clock)
	begin
		if(k_tr = '0') then
			step_reg <= 0;
			st_reg <= (others => '0');
			tr_reg <= '0';
		elsif(clock'event and clock = '1') then
			step_reg <= step_next;
			st_reg <= st_next;
			tr_reg <= tr_next;
		end if;
	end process;
	
	-- next-state logic for music processing
	process(step_reg, st_reg, tr_reg)
		variable step: integer;
		variable st: unsigned(5 downto 0);
		variable tr: std_logic;
	begin
		step := step_reg;
		st := st_reg;
		tr := tr_reg;
		
		if(step_reg < step_r) then
			case st_reg is
				when to_unsigned(0, 6) =>
					st := st_reg + 1;
				when to_unsigned(1, 6) =>
					st := st_reg + 1;
					tr := '0';
				when to_unsigned(2, 6) =>
					st := st_reg + 1;
					tr := '1';
				when to_unsigned(3, 6) =>
					if(go_end_reg = '1') then
						st := st_reg + 1;
					end if;
				when to_unsigned(4, 6) =>
					st := (others => '0');
					step := step_reg + 1;
				when others =>
			end case;
		end if;
		
		step_next <= step;
		st_next <= st;
		tr_next <= tr;
	end process;
	
	-- pitch
	TT <= std_logic_vector(TT_un);
	
	with TT(3 downto 0) select
		key_code1 <= to_unsigned(16#2b#, 8) when "0001",
						 to_unsigned(16#34#, 8) when "0010",
						 to_unsigned(16#33#, 8) when "0011",
						 to_unsigned(16#3b#, 8) when "0100",
						 to_unsigned(16#42#, 8) when "0101",
						 to_unsigned(16#2b#, 8) when "0110",
						 to_unsigned(16#4c#, 8) when "0111",
						 to_unsigned(16#52#, 8) when "1010",
						 to_unsigned(16#f0#, 8) when others;
	
	-- paddle
	with TT(7 downto 4) select
		tmpa <= to_unsigned(16#10#, 16) when "1111",
				  to_unsigned(16#20#, 16) when "1000",
				  to_unsigned(16#30#, 16) when "1001",
				  to_unsigned(16#40#, 16) when "0001",
				  to_unsigned(16#60#, 16) when "0011",
				  to_unsigned(16#80#, 16) when "0010",
				  to_unsigned(16#100#, 16) when "0100",
				  to_unsigned(0, 16) when others;

	with step_reg select
		TT_un <= to_unsigned(16#13#, 8) when 1|49,
					to_unsigned(16#95#, 8) when 2,
					to_unsigned(16#f4#, 8) when 3,
					to_unsigned(16#33#, 8) when 4,
					to_unsigned(16#82#, 8) when 5,
					to_unsigned(16#11#, 8) when 6|55,
					to_unsigned(16#17#, 8) when 7|56,
					to_unsigned(16#31#, 8) when 8,
					to_unsigned(16#85#, 8) when 9|17|25,
					to_unsigned(16#34#, 8) when 10,
					to_unsigned(16#84#, 8) when 11|18|26|50,
					to_unsigned(16#32#, 8) when 12|45,
					to_unsigned(16#82#, 8) when 13|54,
					to_unsigned(16#33#, 8) when 14|37,
					to_unsigned(16#83#, 8) when 15|16|19|23|24|27,
					to_unsigned(16#93#, 8) when 20|28|51,
					to_unsigned(16#f2#, 8) when 21|29|36|38|52,
					to_unsigned(16#81#, 8) when 22|30|31|32|33|34|48|53,
					to_unsigned(16#f1#, 8) when 35|39|44|46,
					to_unsigned(16#87#, 8) when 40|41|42,
					to_unsigned(16#f7#, 8) when 43|47,
					to_unsigned(16#21#, 8) when 57,
					to_unsigned(16#1f#, 8) when others;
					
	-- register logic for key release
	process(clock)
	begin
		if(clock'event and clock = '1') then
			go_end_reg <= go_end_next;
			tmp_reg <= tmp_next;
		end if;
	end process;
	
	go_end_next <= '0' when tr_reg = '0' else
						'1' when tmp_reg > tmpa else
						go_end_reg;
	
	tmp_next <= (others => '0') when tr_reg = '0' else
					tmp_reg when tmp_reg > tmpa else
					tmp_reg + 1;
	
	-- output logic
	key_code <= std_logic_vector(key_code1) when tmp_reg < tmpa - 1 else
					std_logic_vector(to_unsigned(16#f0#, 8));
	
end demo_sound2_arch;