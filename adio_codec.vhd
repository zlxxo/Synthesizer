library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adio_codec is
	port(
		oAUD_DATA, oAUD_LRCK, oAUD_BCK: out std_logic;
		key1_on, key2_on, key3_on, key4_on: in std_logic;
		iSrc_Select: in std_logic_vector(1 downto 0);
		iCLK_18_4, iRST_N: in std_logic;
		sound1, sound2, sound3, sound4: in std_logic_vector(15 downto 0);
		instru: in std_logic
	);
end adio_codec;

architecture adio_codec_arch of adio_codec is
	
	component wave_gen_string is
		port(
			ramp: in std_logic_vector(5 downto 0);
			music_o: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component wave_gen_brass is
		port(
			ramp: in std_logic_vector(5 downto 0);
			music_o: out std_logic_vector(15 downto 0)
		);
	end component;
	
	constant	REF_CLK: integer := 18432000; -- 18.432 MHz
	constant	SAMPLE_RATE: integer := 48000; -- 48 KHz
	constant	DATA_WIDTH: integer := 16; -- 16 Bits
	constant	CHANNEL_NUM: integer := 2; -- Dual Channel
	constant	SIN_SAMPLE_DATA: integer := 48;
	constant	SIN_SANPLE: std_logic_vector(1 downto 0) := "00";
	
	constant BCK_LIMIT: integer := REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2);
	signal bck_div_reg, bck_div_next: unsigned(3 downto 0);
	signal oaud_bck_reg, oaud_bck_next: std_logic;
	
	constant L1X_LIMIT: integer := REF_CLK/(SAMPLE_RATE*2);
	constant L2X_LIMIT: integer := REF_CLK/(SAMPLE_RATE*4);
	constant L4X_LIMIT: integer := REF_CLK/(SAMPLE_RATE*8);
	signal lrck_1x_div_reg, lrck_1x_div_next: unsigned(8 downto 0);
	signal lrck_2x_div_reg, lrck_2x_div_next: unsigned(7 downto 0);
	signal lrck_4x_div_reg, lrck_4x_div_next: unsigned(6 downto 0);
	signal lrck_1x_reg, lrck_1x_next, lrck_2x_reg, lrck_2x_next,
			 lrck_4x_reg, lrck_4x_next: std_logic;
	
	signal sin_cont_reg, sin_cont_next: unsigned(5 downto 0);
	signal sel_cont_reg, sel_cont_next: unsigned(3 downto 0);
	
	signal music1_ramp, music2_ramp, music1_sin, music2_sin, music3_ramp,
			 music4_ramp, music3_sin, music4_sin, music1, music2, music3,
			 music4, sound_o: std_logic_vector(15 downto 0);
	
	signal ramp1_reg, ramp1_next, ramp2_reg, ramp2_next, ramp3_reg,
			 ramp3_next, ramp4_reg, ramp4_next: unsigned(15 downto 0);
	signal ramp1, ramp2, ramp3, ramp4: std_logic_vector(15 downto 0);
	constant RAMP_MAX: integer := 60000;
	signal ramp1_ramp, ramp2_ramp, ramp3_ramp, ramp4_ramp, ramp1_sin,
			 ramp2_sin, ramp3_sin, ramp4_sin: std_logic_vector(5 downto 0);
	
begin
	
	-- register logic for AUD_BCK Generator
	process(iCLK_18_4, iRST_N)
	begin
		if(iRST_N = '0') then
			bck_div_reg <= (others => '0');
			oaud_bck_reg <= '0';
		elsif(iCLK_18_4'event and iCLK_18_4 = '1') then
			bck_div_reg <= bck_div_next;
			oaud_bck_reg <= oaud_bck_next;
		end if;
	end process;
	
	-- next-state logic for AUD_BCK Generator
	bck_div_next <= bck_div_reg + 1 when bck_div_reg < BCK_LIMIT - 1 else
						 (others => '0');
	oaud_bck_next <= oaud_bck_reg when bck_div_reg < BCK_LIMIT - 1 else
						  not oaud_bck_reg;
	
	-- output logic for AUD_BCK Generator
	oAUD_BCK <= oaud_bck_reg;
	
	-- register logic for AUD_LRCK Generator
	process(iCLK_18_4, iRST_N)
	begin
		if(iRST_N = '0') then
			lrck_1x_div_reg <= (others => '0');
			lrck_2x_div_reg <= (others => '0');
			lrck_4x_div_reg <= (others => '0');
			lrck_1x_reg <= '0';
			lrck_2x_reg <= '0';
			lrck_4x_reg <= '0';
		elsif(iCLK_18_4'event and iCLK_18_4 = '1') then
			lrck_1x_div_reg <= lrck_1x_div_next;
			lrck_2x_div_reg <= lrck_2x_div_next;
			lrck_4x_div_reg <= lrck_4x_div_next;
			lrck_1x_reg <= lrck_1x_next;
			lrck_2x_reg <= lrck_2x_next;
			lrck_4x_reg <= lrck_4x_next;
		end if;
	end process;
	
	-- next-state logic for AUD_LRCK Generator
	lrck_1x_div_next <= lrck_1x_div_reg + 1 when lrck_1x_div_reg < L1X_LIMIT else
							  (others => '0');
	
	lrck_1x_next <= lrck_1x_reg when lrck_1x_div_reg < L1X_LIMIT else
						 not lrck_1x_reg;
	
	lrck_2x_div_next <= lrck_2x_div_reg + 1 when lrck_2x_div_reg < L2X_LIMIT else
							  (others => '0');
	
	lrck_2x_next <= lrck_2x_reg when lrck_2x_div_reg < L2X_LIMIT else
						 not lrck_2x_reg;
	
	lrck_4x_div_next <= lrck_4x_div_reg + 1 when lrck_4x_div_reg < L4X_LIMIT else
							  (others => '0');
	
	lrck_4x_next <= lrck_4x_reg when lrck_4x_div_reg < L4X_LIMIT else
						 not lrck_4x_reg;
	
	-- output logic for AUD_LRCK Generator
	oAUD_LRCK <= lrck_1x_reg;
	
	-- register logic for Sin LUT ADDR Generator
	process(lrck_1x_reg, iRST_N)
	begin
		if(iRST_N = '0') then
			sin_cont_reg <= (others => '0');
		elsif(lrck_1x_reg'event and lrck_1x_reg = '0') then
			sin_cont_reg <= sin_cont_next;
		end if;
	end process;
	
	-- next-state logic for Sin LUT ADDR Generator
	sin_cont_next <= sin_cont_reg + 1 when sin_cont_reg < SIN_SAMPLE_DATA else
						  (others => '0');
	
	-- Timbre selection & SoundOut
	music1 <= music1_ramp when instru = '1' else music1_sin;
	music2 <= music2_ramp when instru = '1' else music2_sin;
	music3 <= music3_ramp when instru = '1' else music3_sin;
	music4 <= music4_ramp when instru = '1' else music4_sin;
	sound_o <= std_logic_vector(unsigned(music1) + unsigned(music2) + unsigned(music3)
				  + unsigned(music4));
	
	process(oaud_bck_reg, iRST_N)
	begin
		if(iRST_N = '0') then
			sel_cont_reg <= (others => '0');
		elsif(oaud_bck_reg'event and oaud_bck_reg = '0') then
			sel_cont_reg <= sel_cont_next;
		end if;
	end process;
	
	sel_cont_next <= sel_cont_reg + 1;
	
	oAUD_DATA <= sound_o(to_integer(sel_cont_reg)) when (key4_on = '1' or
					 key3_on = '1' or key2_on = '1' or key1_on = '1') and iSrc_Select = SIN_SANPLE else
					 '0';
	
	-- CH1 Ramp
	process(key1_on, lrck_1x_reg)
	begin
		if(key1_on = '0') then
			ramp1_reg <= (others => '0');
		elsif(lrck_1x_reg'event and lrck_1x_reg = '0') then
			ramp1_reg <= ramp1_next;
		end if;
	end process;
	
	ramp1_next <= (others => '0') when ramp1_reg > RAMP_MAX else
					  ramp1_reg + unsigned(sound1);
	
	-- CH2 Ramp
	process(key2_on, lrck_1x_reg)
	begin
		if(key2_on = '0') then
			ramp2_reg <= (others => '0');
		elsif(lrck_1x_reg'event and lrck_1x_reg = '0') then
			ramp2_reg <= ramp2_next;
		end if;
	end process;
	
	ramp2_next <= (others => '0') when ramp2_reg > RAMP_MAX else
					  ramp2_reg + unsigned(sound2);
	
	-- CH3 Ramp
	process(key3_on, lrck_1x_reg)
	begin
		if(key3_on = '0') then
			ramp3_reg <= (others => '0');
		elsif(lrck_1x_reg'event and lrck_1x_reg = '0') then
			ramp3_reg <= ramp3_next;
		end if;
	end process;
	
	ramp3_next <= (others => '0') when ramp3_reg > RAMP_MAX else
					  ramp3_reg + unsigned(sound3);
	
	-- CH4 Ramp
	process(key4_on, lrck_1x_reg)
	begin
		if(key4_on = '0') then
			ramp4_reg <= (others => '0');
		elsif(lrck_1x_reg'event and lrck_1x_reg = '0') then
			ramp4_reg <= ramp4_next;
		end if;
	end process;
	
	ramp4_next <= (others => '0') when ramp4_reg > RAMP_MAX else
					  ramp4_reg + unsigned(sound4);
	
	-- Ramp address assign
	ramp1 <= std_logic_vector(ramp1_reg);
	ramp2 <= std_logic_vector(ramp2_reg);
	ramp3 <= std_logic_vector(ramp3_reg);
	ramp4 <= std_logic_vector(ramp4_reg);
	ramp1_ramp <= ramp1(15 downto 10) when instru = '1' else "000000";
	ramp2_ramp <= ramp2(15 downto 10) when instru = '1' else "000000";
	ramp3_ramp <= ramp3(15 downto 10) when instru = '1' else "000000";
	ramp4_ramp <= ramp4(15 downto 10) when instru = '1' else "000000";
	ramp1_sin <= ramp1(15 downto 10) when instru = '0' else "000000";
	ramp2_sin <= ramp2(15 downto 10) when instru = '0' else "000000";
	ramp3_sin <= ramp3(15 downto 10) when instru = '0' else "000000";
	ramp4_sin <= ramp4(15 downto 10) when instru = '0' else "000000";
	
	-- String-wave Timbre
	r1: wave_gen_string port map(ramp1_ramp, music1_ramp);
	r2: wave_gen_string port map(ramp2_ramp, music2_ramp);
	r3: wave_gen_string port map(ramp3_ramp, music3_ramp);
	r4: wave_gen_string port map(ramp4_ramp, music4_ramp);

	-- Brass-wave Timbre
	s1: wave_gen_brass port map(ramp1_sin, music1_sin);
	s2: wave_gen_brass port map(ramp2_sin, music2_sin);
	s3: wave_gen_brass port map(ramp3_sin, music3_sin);
	s4: wave_gen_brass port map(ramp4_sin, music4_sin);
	
end adio_codec_arch;