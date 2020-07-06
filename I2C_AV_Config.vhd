library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_AV_Config is
	port(
		iclk, irst_n: in std_logic;
		o_i2c_end, i2c_sclk, i2c_sdat: out std_logic
	);
end I2C_AV_Config;

architecture I2C_AV_Config_arch of I2C_AV_Config is
	
	component I2C_Controller is
		port(
			clock, go, reset: in std_logic;
			i2c_data: in std_logic_vector(23 downto 0);
			i2c_sclk, end_transf, ack: out std_logic;
			i2c_sdat: out std_logic
		);
	end component;

	constant CLK_FREQ: integer := 50000000; -- 50 MHz
	constant I2C_FREQ: integer := 20000; -- 20 KHz
	constant DIVIDER: integer := CLK_FREQ/I2C_FREQ;
	signal mi2c_clk_div_reg, mi2c_clk_div_next: unsigned(15 downto 0);
	signal mi2c_ctrl_clk_reg, mi2c_ctrl_clk_next: std_logic;
	
	signal mi2c_data_reg, mi2c_data_next: std_logic_vector(23 downto 0);
	signal mi2c_go_reg, mi2c_go_next: std_logic;
	signal mi2c_end, mi2c_ack: std_logic;
	
	constant	LUT_SIZE: integer	:=	50;
	signal lut_data_reg, lut_data_next: unsigned(15 downto 0);
	signal lut_index_reg, lut_index_next: integer;
	constant	SET_LIN_L: integer := 0;
	constant	SET_LIN_R: integer := 1;
	constant	SET_HEAD_L: integer := 2;
	constant	SET_HEAD_R: integer := 3;
	constant	A_PATH_CTRL: integer := 4;
	constant	D_PATH_CTRL: integer := 5;
	constant	POWER_ON: integer := 6;
	constant	SET_FORMAT: integer := 7;
	constant	SAMPLE_CTRL: integer := 8;
	constant	SET_ACTIVE: integer := 9;
	constant	SET_VIDEO: integer := 10;
	
	signal mSetup_state_reg, mSetup_state_next: unsigned(3 downto 0); 
	signal o_i2c_end_reg, o_i2c_end_next: std_logic;
	
begin

	u0: I2C_Controller port map(mi2c_ctrl_clk_reg, mi2c_go_reg, irst_n, mi2c_data_reg, i2c_sclk, mi2c_end, mi2c_ack, i2c_sdat);
	
	-- register logic for divider
	process(iclk, irst_n)
	begin
		if(irst_n = '0') then
			mi2c_clk_div_reg <= (others => '0');
			mi2c_ctrl_clk_reg <= '0';
		elsif(iclk'event and iclk = '1') then
			mi2c_clk_div_reg <= mi2c_clk_div_next;
			mi2c_ctrl_clk_reg <= mi2c_ctrl_clk_reg;
		end if;
	end process;
	
	-- next-state logic for divider
	mi2c_clk_div_next <= mi2c_clk_div_reg + 1 when mi2c_clk_div_reg < DIVIDER else
								(others => '0');
	
	mi2c_ctrl_clk_next <= '0' when mi2c_clk_div_reg = DIVIDER and mi2c_ctrl_clk_reg = '1' else
								 '1' when mi2c_clk_div_reg = DIVIDER and mi2c_ctrl_clk_reg = '0' else
								 mi2c_ctrl_clk_reg;
	
	
	-- register logic
	process(mi2c_ctrl_clk_reg, irst_n)
	begin
		if(irst_n = '0') then
			lut_index_reg <= 0;
			mSetup_state_reg <= (others => '0');
			mi2c_go_reg <= '0';
		elsif(mi2c_ctrl_clk_reg'event and mi2c_ctrl_clk_reg = '1') then
			lut_index_reg <= lut_index_next;
			mSetup_state_reg <= mSetup_state_next;
			mi2c_go_reg <= mi2c_go_next;
		end if;
	end process;
	
	process(lut_index_reg, mSetup_state_reg, mi2c_go_reg, mi2c_data_reg)
		variable e, go: std_logic;
		variable data: std_logic_vector(23 downto 0);
		variable state: unsigned(3 downto 0);
		variable index: integer;
	begin
		e := o_i2c_end_reg;
		data := mi2c_data_reg;
		go := mi2c_go_reg;
		state := mSetup_state_reg;
		index := lut_index_reg;
		
		if(lut_index_reg < LUT_SIZE) then
			e := '0';
			case mSetup_state_reg is
				when to_unsigned(0, 4) =>
					if(lut_index_reg < SET_VIDEO) then
						data := std_logic_vector(to_unsigned(16#34#, 8)) & std_logic_vector(lut_data_reg);
					else
						data := std_logic_vector(to_unsigned(16#40#, 8)) & std_logic_vector(lut_data_reg);
						go := '1';
						state := to_unsigned(1, 4);
					end if;
				when to_unsigned(1, 4) =>
					if(mi2c_end = '1') then
						if(mi2c_ack = '0') then
							state := to_unsigned(2, 4);
						else
							state := to_unsigned(0, 4);
							go := '0';
						end if;
					end if;
				when to_unsigned(2, 4) =>
					index :=	lut_index_reg + 1;
					state	:=	to_unsigned(0, 4);
				when others =>
			end case;
		else
			e := '1';
		end if;
		
		o_i2c_end_next <= e;
		mi2c_data_next <= data;
		mi2c_go_next <= go;
		mSetup_state_next <= state;
		lut_index_next <= index;
	end process;
	
	-- register logic for lut data
	process(mi2c_ctrl_clk_reg)
	begin
		if(mi2c_ctrl_clk_reg'event and mi2c_ctrl_clk_reg = '1') then
			lut_data_reg <= lut_data_next;
		end if;
	end process;
	
	-- next-state logic for lut data
	process(lut_data_reg, lut_index_reg)
	begin
		case lut_index_reg is
		--	Audio Config Data
			when SET_LIN_L	=>	lut_data_next <= to_unsigned(16#001A#, 16);
			when SET_LIN_R	=>	lut_data_next <= to_unsigned(16#021A#, 16);
			when SET_HEAD_L => lut_data_next <= to_unsigned(16#047B#, 16);
			when SET_HEAD_R => lut_data_next <= to_unsigned(16#067B#, 16);
			when A_PATH_CTRL =>	lut_data_next <= to_unsigned(16#08F8#, 16);
			when D_PATH_CTRL => lut_data_next <= to_unsigned(16#0A06#, 16);
			when POWER_ON => lut_data_next <= to_unsigned(16#0C00#, 16);
			when SET_FORMAT => lut_data_next <= to_unsigned(16#0E01#, 16);
			when SAMPLE_CTRL => lut_data_next <= to_unsigned(16#1002#, 16);
			when SET_ACTIVE => lut_data_next <= to_unsigned(16#1201#, 16);
		-- Video Config Data
			when SET_VIDEO	=>	lut_data_next <= to_unsigned(16#1500#, 16);
			when SET_VIDEO + 1 => lut_data_next <= to_unsigned(16#1741#, 16);
			when SET_VIDEO + 2 => lut_data_next <= to_unsigned(16#3a16#, 16);
			when SET_VIDEO + 3 => lut_data_next <= to_unsigned(16#5004#, 16);
			when SET_VIDEO + 4 => lut_data_next <= to_unsigned(16#c505#, 16);
			when SET_VIDEO + 5 => lut_data_next <= to_unsigned(16#c480#, 16);
			when SET_VIDEO + 6 => lut_data_next <= to_unsigned(16#0e80#, 16);
			when SET_VIDEO + 7 => lut_data_next <= to_unsigned(16#5020#, 16);
			when SET_VIDEO + 8 => lut_data_next <= to_unsigned(16#5218#, 16);
			when SET_VIDEO + 9 => lut_data_next <= to_unsigned(16#58ed#, 16);
			when SET_VIDEO + 10 => lut_data_next <= to_unsigned(16#77c5#, 16);
			when SET_VIDEO + 11 => lut_data_next <= to_unsigned(16#7c93#, 16);
			when SET_VIDEO + 12 => lut_data_next <= to_unsigned(16#7d00#, 16);
			when SET_VIDEO + 13 => lut_data_next <= to_unsigned(16#d048#, 16);
			when SET_VIDEO + 14 => lut_data_next <= to_unsigned(16#d5a0#, 16);
			when SET_VIDEO + 15 => lut_data_next <= to_unsigned(16#d7ea#, 16);
			when SET_VIDEO + 16 => lut_data_next <= to_unsigned(16#e43e#, 16);
			when SET_VIDEO + 17 => lut_data_next <= to_unsigned(16#ea0f#, 16);
			when SET_VIDEO + 18 => lut_data_next <= to_unsigned(16#3112#, 16);
			when SET_VIDEO + 19 => lut_data_next <= to_unsigned(16#3281#, 16);
			when SET_VIDEO + 20 => lut_data_next <= to_unsigned(16#3384#, 16);
			when SET_VIDEO + 21 => lut_data_next <= to_unsigned(16#37a0#, 16);
			when SET_VIDEO + 22 => lut_data_next <= to_unsigned(16#e580#, 16);
			when SET_VIDEO + 23 => lut_data_next <= to_unsigned(16#e603#, 16);
			when SET_VIDEO + 24 => lut_data_next <= to_unsigned(16#e785#, 16);
			when SET_VIDEO + 25 => lut_data_next <= to_unsigned(16#5000#, 16);
			when SET_VIDEO + 26 => lut_data_next <= to_unsigned(16#5100#, 16);
			when SET_VIDEO + 27 => lut_data_next <= to_unsigned(16#0050#, 16);
			when SET_VIDEO + 28 => lut_data_next <= to_unsigned(16#1000#, 16);
			when SET_VIDEO + 29 => lut_data_next <= to_unsigned(16#0402#, 16);
			when SET_VIDEO + 30 => lut_data_next <= to_unsigned(16#0b00#, 16);
			when SET_VIDEO + 31 => lut_data_next <= to_unsigned(16#0a20#, 16);
			when SET_VIDEO + 32 => lut_data_next <= to_unsigned(16#1100#, 16);
			when SET_VIDEO + 33 => lut_data_next <= to_unsigned(16#2b00#, 16);
			when SET_VIDEO + 34 => lut_data_next <= to_unsigned(16#2c8c#, 16);
			when SET_VIDEO + 35 => lut_data_next <= to_unsigned(16#2df2#, 16);
			when SET_VIDEO + 36 => lut_data_next <= to_unsigned(16#2eee#, 16);
			when SET_VIDEO + 37 => lut_data_next <= to_unsigned(16#2ff4#, 16);
			when SET_VIDEO + 38 => lut_data_next <= to_unsigned(16#30d2#, 16);
			when SET_VIDEO + 39 => lut_data_next <= to_unsigned(16#0e05#, 16);
			when others => lut_data_next <= (others => '0');
		end case;
	end process;
	
	-- output logic
	o_i2c_end <= o_i2c_end_reg;
	
end I2C_AV_Config_arch;