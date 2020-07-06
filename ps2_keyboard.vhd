library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_keyboard is
	port(
		iclk_50, ps2_dat, ps2_clk, sys_clk, reset, reset1: in std_logic;
		scandata: out std_logic_vector(7 downto 0);
		key1_on, key2_on: out std_logic;
		key1_code, key2_code: out std_logic_vector(7 downto 0)
	);
end ps2_keyboard;

architecture ps2_keyboard_arch of ps2_keyboard is
	
	signal mcnt_reg, mcnt_next: unsigned(10 downto 0) := (others => '0');
	signal rev_tr: std_logic;
	signal rc: std_logic_vector(7 downto 0);
	signal host_ack: std_logic;
	signal keyready_reg, keyready_next: std_logic := '0';
	signal revcnt_reg, revcnt_next: unsigned(7 downto 0) := (others => '0');
	signal revcnt: std_logic_vector(7 downto 0);
	signal is_key: std_logic;
	signal keycode_o: unsigned(7 downto 0);
	signal keycode_o_reg, keycode_o_next: std_logic_vector(7 downto 0);
	signal keyboard_off: std_logic;
	signal key1_on_reg, key1_on_next, key2_on_reg, key2_on_next: std_logic := '0';
	signal key1_code_reg, key1_code_next, key2_code_reg, key2_code_next: unsigned(7 downto 0);
	signal scandata_reg, scandata_next: std_logic_vector(7 downto 0);
	signal ps2_clk_syn0, ps2_dat_syn0, ps2_clk_syn1_reg, ps2_clk_syn1_next, ps2_dat_syn1_reg,
			 ps2_dat_syn1_next, ps2_clk_in_reg, ps2_clk_in_next, ps2_dat_in_reg, ps2_dat_in_next : std_logic;
	signal clk_div_reg, clk_div_next: unsigned(8 downto 0) := (others => '0');
	signal clk_div: std_logic_vector(8 downto 0);
	signal clk: std_logic;
	
begin
	
	-- register logic for keyboard initially
	process(reset, sys_clk)
	begin
		if(reset = '0') then
			mcnt_reg <= (others => '0');
		elsif(sys_clk'event and sys_clk = '1') then
			mcnt_reg <= mcnt_next;
		end if;
	end process;
	
	-- next-state logic for keyboard initially
	mcnt_next <= mcnt_reg + 1 when mcnt_reg < 500 else
					 mcnt_reg;
	
	rev_tr <= '1' when mcnt_reg < 12 else '0';
	rc <= std_logic_vector(keycode_o);
	host_ack <= rc(7) xor rc(6) xor rc(5) xor rc(4) xor rc(3) xor rc(2) xor rc(1) xor rc(0) when revcnt_reg = 10 else
					'1';
	
	-- register logic for keyboard scan-code trigger
	process(rev_tr, ps2_clk)
	begin
		if(rev_tr = '1') then
			keyready_reg <= '0';
		elsif(ps2_clk'event and ps2_clk = '0') then
			keyready_reg <= keyready_next;
		end if;
	end process;
	
	-- next-state logic for keyboard scan-code trigger
	revcnt <= std_logic_vector(revcnt_reg);
	keyready_next <= '1' when revcnt(3 downto 0) = "1010" else '0';
	
	
	
	with keycode_o select
		is_key <= '1' when to_unsigned(16#1c#, 8)|to_unsigned(16#1b#, 8)|to_unsigned(16#23#, 8)|
					 to_unsigned(16#2b#, 8)|to_unsigned(16#34#, 8)|to_unsigned(16#33#, 8)|to_unsigned(16#3b#, 8)|
					 to_unsigned(16#42#, 8)|to_unsigned(16#4b#, 8)|to_unsigned(16#4c#, 8)|to_unsigned(16#52#, 8)|
					 to_unsigned(16#5b#, 8)|to_unsigned(16#4d#, 8)|to_unsigned(16#44#, 8)|to_unsigned(16#43#, 8)|
					 to_unsigned(16#35#, 8)|to_unsigned(16#2c#, 8)|to_unsigned(16#24#, 8)|to_unsigned(16#1d#, 8)|
					 to_unsigned(16#15#, 8),
					 '0' when others;
	
	
	
	keyboard_off <= '0'  when mcnt_reg = 200 or reset1 = '0' else '1';
	
	process(keyready_reg)
	begin
		if(keyready_reg'event and keyready_reg = '1') then
			scandata_reg <= scandata_next;
		end if;
	end process;
	
	scandata_next <= keycode_o_reg;
	
	-- output-logic for scandata
	scandata <= scandata_reg;
	
	-- register logic for keys
	process(keyboard_off, keyready_reg)
	begin
		if(keyboard_off = '0') then
			key1_on_reg <= '0';
			key2_on_reg <= '0';
			key1_code_reg <= to_unsigned(16#f0#, 8);
			key2_code_reg <= to_unsigned(16#f0#, 8);
		elsif(keyready_reg'event and keyready_reg = '1') then
			key1_on_reg <= key1_on_next;
			key2_on_reg <= key2_on_next;
			key1_code_reg <= key1_code_next;
			key2_code_reg <= key2_code_next;
		end if;
	end process;
	
	-- next-state logic for keys
	process(key1_code_reg, key2_code_reg, key1_on_reg, key2_on_reg, scandata_reg, is_key)
		variable k1o, k2o: std_logic;
		variable k1c, k2c: unsigned(7 downto 0);
	begin
		k1o := key1_on_reg;
		k2o := key2_on_reg;
		k1c := key1_code_reg;
		k2c := key2_code_reg;
		
		if(scandata_reg = std_logic_vector(to_unsigned(16#f0#, 8))) then
			if(keycode_o_reg = std_logic_vector(key1_code_reg)) then
				k1c := to_unsigned(16#f0#, 8);
				k1o := '0';
			elsif(keycode_o_reg = std_logic_vector(key2_code_reg)) then
				k2c := to_unsigned(16#f0#, 8);
				k2o := '0';
			end if;
		elsif(is_key = '1') then
			if(key1_on_reg = '0' and key2_code_reg /= unsigned(keycode_o_reg)) then
				k1o := '1';
				k1c := unsigned(keycode_o_reg);
			elsif(key2_on_reg = '0' and key1_code_reg /= unsigned(keycode_o_reg)) then
				k2o := '1';
				k2c := unsigned(keycode_o_reg);
			end if;
		end if;
		
		key1_on_next <= k1o;
		key2_on_next <= k2o;
		key1_code_next <= k1c;
		key2_code_next <= k2c;
	end process;
	
	-- output logic for keys
	key1_on <= key1_on_reg;
	key2_on <= key2_on_reg;
	key1_code <= std_logic_vector(key1_code_reg);
	key2_code <= std_logic_vector(key2_code_reg);
	
	ps2_clk_syn0 <= ps2_clk;
	ps2_dat_syn0 <= ps2_dat;
	
	-- register logic
	process(ps2_clk_in_reg)
	begin
		if(ps2_clk_in_reg'event and ps2_clk_in_reg = '1') then
			keycode_o_reg <= keycode_o_next;
		end if;
	end process;
	
	-- register logic for clock divider
	process(iclk_50)
	begin
		if(iclk_50'event and iclk_50 = '1') then
			clk_div_reg <= clk_div_next;
		end if;
	end process;
	
	-- next-state logic for clock divider
	clk_div_next <= clk_div_reg + 1;
	
	clk_div <= std_logic_vector(clk_div_reg);
	clk <= clk_div(8);
	
	-- register logic for synchronization
	process(clk)
	begin
		ps2_clk_syn1_reg <= ps2_clk_syn1_next;
		ps2_clk_in_reg <= ps2_clk_in_next;
		ps2_dat_syn1_reg <= ps2_dat_syn1_next;
		ps2_dat_in_reg <= ps2_dat_in_next;
	end process;
	
	-- next-state logic for synchronization
	ps2_clk_syn1_next <= ps2_clk_syn0;
	ps2_clk_in_next <= ps2_clk_syn1_reg;
	ps2_dat_syn1_next <= ps2_dat_syn0;
	ps2_dat_in_next <= ps2_dat_in_reg;
	
	process(keyboard_off, ps2_clk_in_reg)
	begin
		if(keyboard_off = '0') then
			revcnt_reg <= (others => '0');
		elsif(ps2_clk_in_reg'event and ps2_clk_in_reg = '1') then
			revcnt_reg <= revcnt_next;
		end if;
	end process;
	
	revcnt_next <= revcnt_reg + 1 when revcnt_reg < 10 else
						(others => '0');
	
	keycode_o_next(0) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0001" else keycode_o_reg(0);
	keycode_o_next(1) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0010" else keycode_o_reg(1);
	keycode_o_next(2) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0011" else keycode_o_reg(2);
	keycode_o_next(3) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0100" else keycode_o_reg(3);
	keycode_o_next(4) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0101" else keycode_o_reg(4);
	keycode_o_next(5) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0110" else keycode_o_reg(5);
	keycode_o_next(6) <= ps2_dat_in_reg when revcnt(3 downto 0) = "0111" else keycode_o_reg(6);
	keycode_o_next(7) <= ps2_dat_in_reg when revcnt(3 downto 0) = "1000" else keycode_o_reg(7);
	
	keycode_o <= unsigned(keycode_o_reg);
	
end ps2_keyboard_arch;