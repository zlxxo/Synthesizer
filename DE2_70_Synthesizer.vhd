library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE2_70_Synthesizer is
	port(
		-- CLOCK
		iCLK_50, iCLK_50_2: in std_logic;
		-- LED
		oLEDG: out std_logic_vector(8 downto 0);
		oLEDR: out std_logic_vector(17 downto 0);
		-- KEY
		key: in std_logic_vector(3 downto 0);
		-- SW
		iSW: in std_logic_vector(17 downto 0);
		-- SEG7
		oHEX0_D, oHEX1_D, oHEX2_D, oHEX3_D, oHEX4_D, oHEX5_D, oHEX6_D, 
		oHEX7_D: out std_logic_vector(6 downto 0);
		-- LCD
		oLCD_BLON: out std_logic;
		LCD_D: inout std_logic_vector(7 downto 0);
		oLCD_EN, oLCD_ON, oLCD_RS, oLCD_RW: out std_logic;
		-- PS2
		PS2_CLK, PS2_DAT, PS2_CLK2, PS2_DAT2: inout std_logic;
		-- VGA
		oVGA_B: out std_logic_vector(7 downto 0);
		VGA_BLANK_N, VGA_CLK: out std_logic;
		oVGA_G: out std_logic_vector(7 downto 0);
		VGA_HS: out std_logic;
		oVGA_R: out std_logic_vector(7 downto 0);
		VGA_SYNC_N, VGA_VS: out std_logic;
		-- Audio
		AUD_ADCDAT: in std_logic;
		AUD_ADCLRCK, AUD_BCLK: inout std_logic;
		AUD_DACDAT: out std_logic;
		AUD_DACLRCK: inout std_logic;
		AUD_XCK: out std_logic;
		-- I2C for Audio and Tv-Decode
		I2C_SCLK: out std_logic;
		I2C_SDAT: inout std_logic;
		-- TV Decoder 1
		iTD1_CLK27: in std_logic;
		iTD1_D: in std_logic_vector(7 downto 0);
		iTD1_HS: in std_logic;
		oTD1_RESET_N: out std_logic;
		iTD1_VS: in std_logic
	);
end DE2_70_Synthesizer;

architecture DE2_70_Synthesizer_arch of DE2_70_Synthesizer is
	
	signal I2C_END, AUD_CTRL_CLK: std_logic;
	signal VGA_CLKo_reg, VGA_CLKo_next: unsigned(31 downto 0);
	signal VGA_CLKo: std_logic_vector(31 downto 0);
	signal keyboard_sysclk, demo_clock: std_logic;
	signal demo_code1, demo_code2, scan_code: std_logic_vector(7 downto 0);
	signal get_gate, key1_on, key2_on: std_logic;
	signal key1_code, key2_code: std_logic_vector(7 downto 0);
	signal VGA_R1, VGA_G1, VGA_B1, VGA_R2, VGA_G2, VGA_B2: std_logic;
	
	component SEG7_LUT_8 is
		port(
			iDIG: in std_logic_vector(31 downto 0);
			oSEG0, oSEG1, oSEG2, oSEG3, oSEG4, oSEG5,
			oSEG6, oSEG7: out std_logic_vector(6 downto 0)
		);
	end component;
	
	component I2C_AV_Config is
		port(
			iclk, irst_n: in std_logic;
			o_i2c_end, i2c_sclk, i2c_sdat: out std_logic
		);
	end component;
	
	component VGA_Audio_PLL is
		port(
			areset: in std_logic := '0';
			inclk0 : in std_logic := '0';
			c0	: out std_logic ;
			c1	: out std_logic ;
			c2	: out std_logic 
		);
	end component;
	signal c0, c2: std_logic;
	
	component demo_sound1 is
		port(
			clock, k_tr: in std_logic;
			key_code: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component demo_sound2 is
		port(
			clock, k_tr: in std_logic;
			key_code: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component ps2_keyboard is
		port(
			iclk_50, ps2_dat, ps2_clk, sys_clk, reset, reset1: in std_logic;
			scandata: out std_logic_vector(7 downto 0);
			key1_on, key2_on: out std_logic;
			key1_code, key2_code: out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal sound1, sound2, sound3, sound4: std_logic_vector(15 downto 0);
	signal sound_off1, sound_off2, sound_off3, sound_off4: std_logic;
	signal sound_code1, sound_code2, sound_code3, sound_code4: std_logic_vector(7 downto 0);
	
	component staff is
		port(
			VGA_CLK: in std_logic;
			scan_code1, scan_code2, scan_code3, scan_code4: in std_logic_vector(7 downto 0);
			vga_sync, vga_h_sync, vga_v_sync, inDisplayArea, vga_R, vga_G, vga_B: out std_logic;
			sound1, sound2, sound3, sound4: out std_logic_vector(15 downto 0);
			sound_off1, sound_off2, sound_off3, sound_off4: out std_logic
		);
	end component;
	
	component adio_codec is
		port(
			oAUD_DATA, oAUD_LRCK, oAUD_BCK: out std_logic;
			KEY1_on, KEY2_on, KEY3_on, KEY4_on: in std_logic;
			iSrc_Select: in std_logic_vector(1 downto 0);
			iCLK_18_4, iRST_N: in std_logic;
			sound1, sound2, sound3, sound4: in std_logic_vector(15 downto 0);
			instru: in std_logic
		);
	end component;
	
	component LCD_TEST is
		port(
			iCLK, iRST_N: in std_logic;
			LCD_DATA: out std_logic_vector(7 downto 0);
			LCD_RW, LCD_EN, LCD_RS: out std_logic
		);
	end component;
	
	component DeBUG_TEST is
		port(
			iCLK, iRST_N, isound_off1, isound_off2: in std_logic;
			oSin_CLK: out std_logic
		);
	end component;
	
	signal oSin_CLK: std_logic;
	
begin
	
	PS2_DAT2 <= '1';	
	PS2_CLK2 <= '1';
	
	-- TV DECODER ENABLE
	oTD1_RESET_N <= '1';
	
	-- 7-SEG 
	u0: SEG7_LUT_8 port map(std_logic_vector(to_unsigned(16#00001112#, 32)),
	oHEX0_D, oHEX1_D, oHEX2_D, oHEX3_D, oHEX4_D, oHEX5_D, oHEX6_D, oHEX7_D);
	
	-- I2C
	u7: I2C_AV_Config port map(iCLK_50, key(0), I2C_END, I2C_SCLK, I2C_SDAT);
	
	-- AUDIO SOUND
	AUD_ADCLRCK <= AUD_DACLRCK;
	AUD_XCK <= AUD_CTRL_CLK;
	
	-- AUDIO PLL
	u1: VGA_Audio_PLL port map(not I2C_END, iTD1_CLK27, c0, AUD_CTRL_CLK, c2);
	
	-- TIME & CLOCK Generater //
	keyboard_sysclk <= VGA_CLKo(12);
	demo_clock <= VGA_CLKo(18); 
	VGA_CLK <= VGA_CLKo(0);
	process(iCLK_50)
	begin
		if(iCLK_50'event and iCLK_50 = '1') then
			VGA_CLKo_reg <= VGA_CLKo_next;
		end if;
	end process;
	VGA_CLKo_next <= VGA_CLKo_reg + 1;
	VGA_CLKo <= std_logic_vector(VGA_CLKo_reg);
	
	-- DEMO Sound (CH1)
	dd1: demo_sound1 port map(demo_clock, key(1) and key(0), demo_code1);
	
	-- DEMO Sound (CH1)
	dd2: demo_sound2 port map(demo_clock, key(1) and key(0), demo_code2);
	
	-- keyboard Scan
	keyboard: ps2_keyboard port map(iCLK_50, PS2_DAT, PS2_CLK, keyboard_sysclk,
	key(3), key(2), scan_code, key1_on, key2_on, key1_code, key2_code);
	
	-- Sound Select
	sound_code1 <= demo_code1 when iSW(9) = '0' else key1_code;
	sound_code2 <= demo_code2 when iSW(9) = '0' else key2_code;
	sound_code3 <= std_logic_vector(to_unsigned(16#f0#, 8));
	sound_code4 <= std_logic_vector(to_unsigned(16#f0#, 8));
	
	-- Staff Display & Sound Output 
	oVGA_R <= std_logic_vector(to_unsigned(16#3f0#, 8)) when VGA_R1 = '1' else
				std_logic_vector(to_unsigned(0, 8));
	oVGA_G <= std_logic_vector(to_unsigned(16#3f0#, 8)) when VGA_G1 = '1' else
				std_logic_vector(to_unsigned(0, 8));
	oVGA_B <= std_logic_vector(to_unsigned(16#3f0#, 8)) when VGA_B1 = '1' else
				std_logic_vector(to_unsigned(0, 8));
	st1: staff port map(VGA_CLKo(0), sound_code1, sound_code2, sound_code3, sound_code4,
	VGA_SYNC_N, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_R1, VGA_G1, VGA_B1,
	sound1, sound2, sound3, sound4, sound_off1, sound_off2, sound_off3, sound_off4);
	
	-- LED Display
	oLEDR(9 downto 6) <= sound_off4 & sound_off3 & sound_off2 & sound_off1;
	oLEDG(7 downto 0) <= scan_code;
	
	-- 2CH Audio Sound output -- Audio Generater
	ad1: adio_codec port map(AUD_DACDAT, AUD_DACLRCK, AUD_BCLK, (not iSW(1)) and sound_off1,
	(not iSW(2)) and sound_off2, '0', '0', "00", AUD_CTRL_CLK, key(0), sound1, sound2,
	sound3, sound4, iSW(0));
	
	-- LCD 
	oLCD_ON <= '1';
	oLCD_BLON	<=	'1';	
	u5: LCD_TEST port map(iCLK_50, key(0) and I2C_END, LCD_D, oLCD_RW, oLCD_EN, oLCD_RS);
	
	-- TEST DeBUG
	u6: DeBUG_TEST port map(iCLK_50_2, key(0), sound_off1, sound_off2, oSin_CLK);
	
end DE2_70_Synthesizer_arch;