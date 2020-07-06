library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_Controller is
	port(
		clock, go, reset: in std_logic;
		i2c_data: in std_logic_vector(23 downto 0);
		i2c_sclk, end_transf, ack: out std_logic;
		i2c_sdat: out std_logic
	);
end I2C_Controller;

architecture I2C_Controller_arch of I2C_Controller is

	constant MAX_COUNTER: unsigned(5 downto 0) := (others => '1');
	signal sd_counter_reg, sd_counter_next: unsigned(5 downto 0);
	
	signal sclk_reg, end_reg: std_logic := '1';
	signal sdo_reg ,ack1_reg, ack2_reg, ack3_reg: std_logic := '0';
	signal sdo_next, ack1_next, ack2_next, ack3_next, sclk_next, end_next: std_logic;
	signal sclk_param: std_logic;
	signal sd_reg: std_logic_vector(23 downto 0);
	signal sd_next: std_logic_vector(23 downto 0);
	signal i2c_sdat_r: std_logic;
	
begin

	-- register logic for counter
	process(reset, clock)
	begin
		if(reset = '0') then
			sd_counter_reg <= (others => '1');
		elsif(clock'event and clock = '1') then
			sd_counter_reg <= sd_counter_next;
		end if;
	end process;
	
	-- next-state logic for counter
	sd_counter_next <= (others => '0') when go = '0' else
							 sd_counter_reg + 1 when sd_counter_reg < MAX_COUNTER else
							 sd_counter_reg;
	-- register logic
	process(reset, clock)
	begin
		if(reset = '0') then
			sdo_reg <= '1';
			sclk_reg <= '1';
			end_reg <= '1';
			ack1_reg <= '0';
			ack2_reg <= '0';
			ack3_reg <= '0';
			sd_reg <= std_logic_vector(to_unsigned(0, 24));
		elsif(clock'event and clock = '1') then
			sdo_reg <= sdo_next;
			sclk_reg <= sclk_next;
			end_reg <= end_next;
			ack1_reg <= ack1_next;
			ack2_reg <= ack2_next;
			ack3_reg <= ack3_next;
			sd_reg <= sd_next;
		end if;
	end process;
	
	-- next-state logic for counter
	process(sd_counter_reg, sdo_reg, sclk_reg, end_reg, ack1_reg, ack2_reg, ack3_reg)
		variable s, sc, e, a1, a2, a3: std_logic;
		variable sd: std_logic_vector(23 downto 0);
	begin
		s := sdo_reg;
		sc := sclk_reg;
		e := end_reg;
		a1 := ack1_reg;
		a2 := ack2_reg;
		a3 := ack3_reg;
		sd := sd_reg;
		
		case sd_counter_reg is
			when to_unsigned(0, 6) =>
				a1 := '0';
				a2 := '0';
				a3 := '0';
				e := '0';
				s := '1';
				sc := '1';
			when to_unsigned(1, 6) => -- start
				sd := i2c_data;
				s := '0';
			when to_unsigned(2, 6) =>
				sc := '0';
			when to_unsigned(3, 6) => -- slave addr
				s := sd_reg(23);
			when to_unsigned(4, 6) =>
				s := sd_reg(22);
			when to_unsigned(5, 6) =>
				s := sd_reg(21);
			when to_unsigned(6, 6) =>
				s := sd_reg(20);
			when to_unsigned(7, 6) =>
				s := sd_reg(19);
			when to_unsigned(8, 6) =>
				s := sd_reg(18);
			when to_unsigned(9, 6) =>
				s := sd_reg(17);
			when to_unsigned(10, 6) =>
				s := sd_reg(16);
			when to_unsigned(11, 6) => -- ack
				s := '1';
			when to_unsigned(12, 6) => -- sub addr
				s := sd_reg(15);
				a1 := i2c_sdat_r;
			when to_unsigned(13, 6) =>
				s := sd_reg(14);
			when to_unsigned(14, 6) =>
				s := sd_reg(13);
			when to_unsigned(15, 6) =>
				s := sd_reg(12);
			when to_unsigned(16, 6) =>
				s := sd_reg(11);
			when to_unsigned(17, 6) =>
				s := sd_reg(10);
			when to_unsigned(18, 6) =>
				s := sd_reg(9);
			when to_unsigned(19, 6) =>
				s := sd_reg(8);
			when to_unsigned(20, 6) => -- ack
				s := '1';
			when to_unsigned(21, 6) =>
				s := sd_reg(7);
				a2 := i2c_sdat_r;
			when to_unsigned(22, 6) => -- data
				s := sd_reg(6);
			when to_unsigned(23, 6) =>
				s := sd_reg(5);
			when to_unsigned(24, 6) =>
				s := sd_reg(4);
			when to_unsigned(25, 6) =>
				s := sd_reg(3);
			when to_unsigned(26, 6) =>
				s := sd_reg(2);
			when to_unsigned(27, 6) =>
				s := sd_reg(1);
			when to_unsigned(28, 6) =>
				s := sd_reg(0);
			when to_unsigned(29, 6) =>
				s := '1';
			when to_unsigned(30, 6) => --  stop
				s := '0';
				sc := '0';
				a3 := i2c_sdat_r;
			when to_unsigned(31, 6) =>
				sc := '1';
			when to_unsigned(32, 6) =>
				s := '1';
				e := '1';
			when others =>
		end case;
		
		sdo_next <= s;
		sclk_next <= sc;
		end_next <= e;
		ack1_next <= a1;
		ack2_next <= a2;
		ack3_next <= a3;
		sd_next <= sd;
	end process;
	
	-- output logic
	ack <= ack1_reg or ack2_reg or ack3_reg;
	end_transf <= end_reg;
	
	-- pomocni signal
	sclk_param <= '0' when sd_counter_reg < 4 or sd_counter_reg > 30 else
					  not clock;
	i2c_sclk <= sclk_reg or sclk_param;
	i2c_sdat_r <= '1' when sdo_reg = '1' else '0';
	i2c_sdat <= i2c_sdat_r;
	
end I2C_Controller_arch;