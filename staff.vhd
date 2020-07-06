library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity staff is
	port(
		VGA_CLK: in std_logic;
		scan_code1, scan_code2, scan_code3, scan_code4: in std_logic_vector(7 downto 0);
		vga_sync, vga_h_sync, vga_v_sync, inDisplayArea, vga_R, vga_G, vga_B: out std_logic;
		sound1, sound2, sound3, sound4: out std_logic_vector(15 downto 0);
		sound_off1, sound_off2, sound_off3, sound_off4: out std_logic
	);
end staff;

architecture staff_arch of staff is
	
	component vga_time_generator is
		port(
			pixel_clk: in std_logic;
			h_disp, h_fporch, h_sync, h_bporch,
			v_disp, v_fporch, v_sync, v_bporch: in std_logic_vector(11 downto 0);
			vga_hs, vga_vs, vga_blank: out std_logic;
			counterY, counterX: out std_logic_vector(11 downto 0)
		);
	end component;
	
	constant h_disp: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(640, 12));
	constant h_fporch: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(16, 12));
	constant h_sync: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(96, 12));
	constant h_bporch: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(48, 12));
	constant v_disp: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(480, 12));
	constant v_fporch: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(10, 12));
	constant v_sync: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(2, 12));
	constant v_bporch: std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(33, 12));
	
	component bar_white is
		port(
			CounterY: in std_logic_vector(11 downto 0);
			L_5, L_6, L_7, M_1, M_2, M_3, M_4, M_5, M_6,
			M_7, H_1, H_2, H_3, H_4, H_5: out std_logic
		);
	end component;
	
	component bar_blank is
		port(
			CounterY: in std_logic_vector(11 downto 0);
			Hu4, Hu2, Hu1, Mu6, Mu5, Mu4,
			Mu2, Mu1, Lu6, Lu5, Lu4: out std_logic
		);
	end component;
	
	component bar_big is
		port(
			x, y, org_x, org_y, line_x, line_y: in std_logic_vector(11 downto 0);
			bar_space: out std_logic
		);
	end component;
	
	signal CounterX, CounterY: std_logic_vector(11 downto 0);
	signal L_5_tr, L_6_tr, L_7_tr, M_1_tr, M_2_tr, M_3_tr, M_4_tr, M_5_tr,
	M_6_tr, M_7_tr, H_1_tr, H_2_tr, H_3_tr, H_4_tr, H_5_tr, Hu4_tr, Hu2_tr,
	Hu1_tr, Mu6_tr, Mu5_tr, Mu4_tr, Mu2_tr, Mu1_tr, Lu6_tr, Lu5_tr, Lu4_tr: std_logic;
	signal L2_5_tr, L2_6_tr, L2_7_tr, M2_1_tr, M2_2_tr, M2_3_tr, M2_4_tr, M2_5_tr,
	M2_6_tr, M2_7_tr, H2_1_tr, H2_2_tr, H2_3_tr, H2_4_tr, H2_5_tr, H2u4_tr, H2u2_tr,
	H2u1_tr, M2u6_tr, M2u5_tr, M2u4_tr, M2u2_tr, M2u1_tr, L2u6_tr, L2u5_tr, L2u4_tr: std_logic;
	signal L3_5_tr, L3_6_tr, L3_7_tr, M3_1_tr, M3_2_tr, M3_3_tr, M3_4_tr, M3_5_tr,
	M3_6_tr, M3_7_tr, H3_1_tr, H3_2_tr, H3_3_tr, H3_4_tr, H3_5_tr, H3u4_tr, H3u2_tr,
	H3u1_tr, M3u6_tr, M3u5_tr, M3u4_tr, M3u2_tr, M3u1_tr, L3u6_tr, L3u5_tr, L3u4_tr: std_logic;
	signal L4_5_tr, L4_6_tr, L4_7_tr, M4_1_tr, M4_2_tr, M4_3_tr, M4_4_tr, M4_5_tr,
	M4_6_tr, M4_7_tr, H4_1_tr, H4_2_tr, H4_3_tr, H4_4_tr, H4_5_tr, H4u4_tr, H4u2_tr,
	H4u1_tr, M4u6_tr, M4u5_tr, M4u4_tr, M4u2_tr, M4u1_tr, L4u6_tr, L4u5_tr, L4u4_tr: std_logic;
	signal L_5, L_6, L_7, M_1, M_2, M_3, M_4, M_5, M_6, M_7, H_1, H_2, H_3, H_4, H_5: std_logic;
	
	constant ydeta: integer := 30;
	constant yd_t: integer := ydeta + 2;
	constant yd_t0: integer := 0;
	constant yd_t1: integer := yd_t;
	constant yd_t2: integer := yd_t*2;
	constant yd_t3: integer := yd_t*3;
	constant yd_t4: integer := yd_t*4;
	constant yd_t5: integer := yd_t*5;
	constant yd_t6: integer := yd_t*6;
	constant yd_t7: integer := yd_t*7;
	constant yd_t8: integer := yd_t*8;
	constant yd_t9: integer := yd_t*9;
	constant yd_t10: integer := yd_t*10;
	constant yd_t11: integer := yd_t*11;
	constant yd_t12: integer := yd_t*12;
	constant yd_t13: integer := yd_t*13;
	constant yd_t14: integer := yd_t*14;
	constant yd_t15: integer := yd_t*15;
	signal y_org: integer;
	signal white_x: integer;
	signal white_bar: std_logic;
	
	signal Hu4, Hu2, Hu1, Mu6, Mu5, Mu4, Mu2, Mu1, Lu6, Lu5, Lu4: std_logic;
	signal by_org: integer;
	signal blank_x: integer;
	signal blank_bar: std_logic;
	signal ida: std_logic;
	
begin
	
	vga_sync <= '1';
	sound_off1 <= '0' when scan_code1 = "11110000" else '1';
	sound_off2 <= '0' when scan_code2 = "11110000" else '1';
	sound_off3 <= '0' when scan_code3 = "11110000" else '1';
	sound_off4 <= '0' when scan_code4 = "11110000" else '1';
	
	vga0: vga_time_generator port map(VGA_CLK, h_disp, h_fporch, h_sync, h_bporch, v_disp,
	v_fporch, v_sync, v_bporch, vga_h_sync, vga_v_sync, ida, CounterX, CounterY);
	
	-- Channel-1 Trigger
	L_5_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#1c#, 8)) else '0';
	L_6_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#1b#, 8)) else '0';
	L_7_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#23#, 8)) else '0';
	M_1_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#2b#, 8)) else '0';
	M_2_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#34#, 8)) else '0';
	M_3_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#33#, 8)) else '0';
	M_4_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#3b#, 8)) else '0';
	M_5_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#42#, 8)) else '0';
	M_6_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#4b#, 8)) else '0';
	M_7_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#4c#, 8)) else '0';
	H_1_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#52#, 8)) else '0';
	H_2_tr <= '0';
	H_3_tr <= '0';
	H_4_tr <= '0';
	H_5_tr <= '0';
	Hu4_tr <= '0';
	Hu2_tr <= '0';
	Hu1_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#5b#, 8)) else '0';
	Mu6_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#4d#, 8)) else '0';
	Mu5_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#44#, 8)) else '0';
	Mu4_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#43#, 8)) else '0';
	Mu2_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#53#, 8)) else '0';
	Mu1_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#2c#, 8)) else '0';
	Lu6_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#24#, 8)) else '0';
	Lu5_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#1d#, 8)) else '0';
	Lu4_tr <= '1' when scan_code1 = std_logic_vector(to_unsigned(16#15#, 8)) else '0';
	
	-- channel-1 frequency
	sound1 <= std_logic_vector(to_unsigned(400, 16)) when Lu4_tr = '1' else
				 std_logic_vector(to_unsigned(423, 16)) when L_5_tr = '1' else
				 std_logic_vector(to_unsigned(448, 16)) when Lu5_tr = '1' else
				 std_logic_vector(to_unsigned(475, 16)) when L_6_tr = '1' else
				 std_logic_vector(to_unsigned(503, 16)) when Lu6_tr = '1' else
				 std_logic_vector(to_unsigned(533, 16)) when L_7_tr = '1' else
				 std_logic_vector(to_unsigned(565, 16)) when M_1_tr = '1' else
				 std_logic_vector(to_unsigned(599, 16)) when Mu1_tr = '1' else
				 std_logic_vector(to_unsigned(634, 16)) when M_2_tr = '1' else
				 std_logic_vector(to_unsigned(672, 16)) when Mu2_tr = '1' else
				 std_logic_vector(to_unsigned(712, 16)) when M_3_tr = '1' else
				 std_logic_vector(to_unsigned(755, 16)) when M_4_tr = '1' else
				 std_logic_vector(to_unsigned(800, 16)) when Mu4_tr = '1' else
				 std_logic_vector(to_unsigned(847, 16)) when M_5_tr = '1' else
				 std_logic_vector(to_unsigned(897, 16)) when Mu5_tr = '1' else
				 std_logic_vector(to_unsigned(951, 16)) when M_6_tr = '1' else
				 std_logic_vector(to_unsigned(1007, 16)) when Mu6_tr = '1' else
				 std_logic_vector(to_unsigned(1067, 16)) when M_7_tr = '1' else
				 std_logic_vector(to_unsigned(1131, 16)) when H_1_tr = '1' else
				 std_logic_vector(to_unsigned(1198, 16)) when Hu1_tr = '1' else
				 std_logic_vector(to_unsigned(1, 16));
	
	-- Channel-2 Trigger
	L2_5_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#1c#, 8)) else '0';
	L2_6_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#1b#, 8)) else '0';
	L2_7_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#23#, 8)) else '0';
	M2_1_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#2b#, 8)) else '0';
	M2_2_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#34#, 8)) else '0';
	M2_3_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#33#, 8)) else '0';
	M2_4_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#3b#, 8)) else '0';
	M2_5_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#42#, 8)) else '0';
	M2_6_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#4b#, 8)) else '0';
	M2_7_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#4c#, 8)) else '0';
	H2_1_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#52#, 8)) else '0';
	H2_2_tr <= '0';
	H2_3_tr <= '0';
	H2_4_tr <= '0';
	H2_5_tr <= '0';
	H2u4_tr <= '0';
	H2u2_tr <= '0';
	H2u1_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#5b#, 8)) else '0';
	M2u6_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#4d#, 8)) else '0';
	M2u5_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#44#, 8)) else '0';
	M2u4_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#43#, 8)) else '0';
	M2u2_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#53#, 8)) else '0';
	M2u1_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#2c#, 8)) else '0';
	L2u6_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#24#, 8)) else '0';
	L2u5_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#1d#, 8)) else '0';
	L2u4_tr <= '1' when scan_code2 = std_logic_vector(to_unsigned(16#15#, 8)) else '0';
	
	-- channel-2 frequency
	sound2 <= std_logic_vector(to_unsigned(400, 16)) when L2u4_tr = '1' else
				 std_logic_vector(to_unsigned(423, 16)) when L2_5_tr = '1' else
				 std_logic_vector(to_unsigned(448, 16)) when L2u5_tr = '1' else
				 std_logic_vector(to_unsigned(475, 16)) when L2_6_tr = '1' else
				 std_logic_vector(to_unsigned(503, 16)) when L2u6_tr = '1' else
				 std_logic_vector(to_unsigned(533, 16)) when L2_7_tr = '1' else
				 std_logic_vector(to_unsigned(565, 16)) when M2_1_tr = '1' else
				 std_logic_vector(to_unsigned(599, 16)) when M2u1_tr = '1' else
				 std_logic_vector(to_unsigned(634, 16)) when M2_2_tr = '1' else
				 std_logic_vector(to_unsigned(672, 16)) when M2u2_tr = '1' else
				 std_logic_vector(to_unsigned(712, 16)) when M2_3_tr = '1' else
				 std_logic_vector(to_unsigned(755, 16)) when M2_4_tr = '1' else
				 std_logic_vector(to_unsigned(800, 16)) when M2u4_tr = '1' else
				 std_logic_vector(to_unsigned(847, 16)) when M2_5_tr = '1' else
				 std_logic_vector(to_unsigned(897, 16)) when M2u5_tr = '1' else
				 std_logic_vector(to_unsigned(951, 16)) when M2_6_tr = '1' else
				 std_logic_vector(to_unsigned(1007, 16)) when M2u6_tr = '1' else
				 std_logic_vector(to_unsigned(1067, 16)) when M2_7_tr = '1' else
				 std_logic_vector(to_unsigned(1131, 16)) when H2_1_tr = '1' else
				 std_logic_vector(to_unsigned(1198, 16)) when H2u1_tr = '1' else
				 std_logic_vector(to_unsigned(1, 16));
	
	-- Channel-3 Trigger
	L3_5_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#1c#, 8)) else '0';
	L3_6_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#1b#, 8)) else '0';
	L3_7_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#23#, 8)) else '0';
	M3_1_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#2b#, 8)) else '0';
	M3_2_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#34#, 8)) else '0';
	M3_3_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#33#, 8)) else '0';
	M3_4_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#3b#, 8)) else '0';
	M3_5_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#42#, 8)) else '0';
	M3_6_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#4b#, 8)) else '0';
	M3_7_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#4c#, 8)) else '0';
	H3_1_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#52#, 8)) else '0';
	H3_2_tr <= '0';
	H3_3_tr <= '0';
	H3_4_tr <= '0';
	H3_5_tr <= '0';
	H3u4_tr <= '0';
	H3u2_tr <= '0';
	H3u1_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#5b#, 8)) else '0';
	M3u6_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#4d#, 8)) else '0';
	M3u5_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#44#, 8)) else '0';
	M3u4_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#43#, 8)) else '0';
	M3u2_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#53#, 8)) else '0';
	M3u1_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#2c#, 8)) else '0';
	L3u6_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#24#, 8)) else '0';
	L3u5_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#1d#, 8)) else '0';
	L3u4_tr <= '1' when scan_code3 = std_logic_vector(to_unsigned(16#15#, 8)) else '0';
	
	-- channel-3 frequency
	sound3 <= std_logic_vector(to_unsigned(400, 16)) when L3u4_tr = '1' else
				 std_logic_vector(to_unsigned(423, 16)) when L3_5_tr = '1' else
				 std_logic_vector(to_unsigned(448, 16)) when L3u5_tr = '1' else
				 std_logic_vector(to_unsigned(475, 16)) when L3_6_tr = '1' else
				 std_logic_vector(to_unsigned(503, 16)) when L3u6_tr = '1' else
				 std_logic_vector(to_unsigned(533, 16)) when L3_7_tr = '1' else
				 std_logic_vector(to_unsigned(565, 16)) when M3_1_tr = '1' else
				 std_logic_vector(to_unsigned(599, 16)) when M3u1_tr = '1' else
				 std_logic_vector(to_unsigned(634, 16)) when M3_2_tr = '1' else
				 std_logic_vector(to_unsigned(672, 16)) when M3u2_tr = '1' else
				 std_logic_vector(to_unsigned(712, 16)) when M3_3_tr = '1' else
				 std_logic_vector(to_unsigned(755, 16)) when M3_4_tr = '1' else
				 std_logic_vector(to_unsigned(800, 16)) when M3u4_tr = '1' else
				 std_logic_vector(to_unsigned(847, 16)) when M3_5_tr = '1' else
				 std_logic_vector(to_unsigned(897, 16)) when M3u5_tr = '1' else
				 std_logic_vector(to_unsigned(951, 16)) when M3_6_tr = '1' else
				 std_logic_vector(to_unsigned(1007, 16)) when M3u6_tr = '1' else
				 std_logic_vector(to_unsigned(1067, 16)) when M3_7_tr = '1' else
				 std_logic_vector(to_unsigned(1131, 16)) when H3_1_tr = '1' else
				 std_logic_vector(to_unsigned(1198, 16)) when H3u1_tr = '1' else
				 std_logic_vector(to_unsigned(1, 16));
	
	-- Channel-4 Trigger
	L4_5_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#1c#, 8)) else '0';
	L4_6_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#1b#, 8)) else '0';
	L4_7_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#23#, 8)) else '0';
	M4_1_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#2b#, 8)) else '0';
	M4_2_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#34#, 8)) else '0';
	M4_3_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#33#, 8)) else '0';
	M4_4_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#3b#, 8)) else '0';
	M4_5_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#42#, 8)) else '0';
	M4_6_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#4b#, 8)) else '0';
	M4_7_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#4c#, 8)) else '0';
	H4_1_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#52#, 8)) else '0';
	H4_2_tr <= '0';
	H4_3_tr <= '0';
	H4_4_tr <= '0';
	H4_5_tr <= '0';
	H4u4_tr <= '0';
	H4u2_tr <= '0';
	H4u1_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#5b#, 8)) else '0';
	M4u6_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#4d#, 8)) else '0';
	M4u5_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#44#, 8)) else '0';
	M4u4_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#43#, 8)) else '0';
	M4u2_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#53#, 8)) else '0';
	M4u1_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#2c#, 8)) else '0';
	L4u6_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#24#, 8)) else '0';
	L4u5_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#1d#, 8)) else '0';
	L4u4_tr <= '1' when scan_code4 = std_logic_vector(to_unsigned(16#15#, 8)) else '0';
	
	-- channel-1 frequency
	sound4 <= std_logic_vector(to_unsigned(400, 16)) when L4u4_tr = '1' else
				 std_logic_vector(to_unsigned(423, 16)) when L4_5_tr = '1' else
				 std_logic_vector(to_unsigned(448, 16)) when L4u5_tr = '1' else
				 std_logic_vector(to_unsigned(475, 16)) when L4_6_tr = '1' else
				 std_logic_vector(to_unsigned(503, 16)) when L4u6_tr = '1' else
				 std_logic_vector(to_unsigned(533, 16)) when L4_7_tr = '1' else
				 std_logic_vector(to_unsigned(565, 16)) when M4_1_tr = '1' else
				 std_logic_vector(to_unsigned(599, 16)) when M4u1_tr = '1' else
				 std_logic_vector(to_unsigned(634, 16)) when M4_2_tr = '1' else
				 std_logic_vector(to_unsigned(672, 16)) when M4u2_tr = '1' else
				 std_logic_vector(to_unsigned(712, 16)) when M4_3_tr = '1' else
				 std_logic_vector(to_unsigned(755, 16)) when M4_4_tr = '1' else
				 std_logic_vector(to_unsigned(800, 16)) when M4u4_tr = '1' else
				 std_logic_vector(to_unsigned(847, 16)) when M4_5_tr = '1' else
				 std_logic_vector(to_unsigned(897, 16)) when M4u5_tr = '1' else
				 std_logic_vector(to_unsigned(951, 16)) when M4_6_tr = '1' else
				 std_logic_vector(to_unsigned(1007, 16)) when M4u6_tr = '1' else
				 std_logic_vector(to_unsigned(1067, 16)) when M4_7_tr = '1' else
				 std_logic_vector(to_unsigned(1131, 16)) when H4_1_tr = '1' else
				 std_logic_vector(to_unsigned(1198, 16)) when H4u1_tr = '1' else
				 std_logic_vector(to_unsigned(1, 16));
	
	bar1: bar_white port map(CounterY, L_5, L_6, L_7, M_1, M_2, M_3, M_4, M_5,
	M_6, M_7, H_1, H_2, H_3, H_4, H_5);
	
	y_org <= yd_t0 when H_5 = '1' else
				yd_t1 when H_4 = '1' else
				yd_t2 when H_3 = '1' else
				yd_t3 when H_2 = '1' else
				yd_t4 when H_1 = '1' else
				yd_t5 when M_7 = '1' else
				yd_t6 when M_6 = '1' else
				yd_t7 when M_5 = '1' else
				yd_t8 when M_4 = '1' else
				yd_t9 when M_3 = '1' else
				yd_t10 when M_2 = '1' else
				yd_t11 when M_1 = '1' else
				yd_t12 when L_7 = '1' else
				yd_t13 when L_6 = '1' else
				yd_t14;
	
	-- White-key play
	white_x <= 110 when (L4_5_tr = '1' or L3_5_tr = '1' or L2_5_tr = '1' or L_5_tr = '1') and L_5 = '1' else
				  110 when (L4_6_tr = '1' or L3_6_tr = '1' or L2_6_tr = '1' or L_6_tr = '1') and L_6 = '1' else
				  110 when (L4_7_tr = '1' or L3_7_tr = '1' or L2_7_tr = '1' or L_7_tr = '1') and L_7 = '1' else
				  110 when (M4_1_tr = '1' or M3_1_tr = '1' or M2_1_tr = '1' or M_1_tr = '1') and M_1 = '1' else
				  110 when (M4_2_tr = '1' or M3_2_tr = '1' or M2_2_tr = '1' or M_2_tr = '1') and M_2 = '1' else
				  110 when (M4_3_tr = '1' or M3_3_tr = '1' or M2_3_tr = '1' or M_3_tr = '1') and M_3 = '1' else
				  110 when (M4_4_tr = '1' or M3_4_tr = '1' or M2_4_tr = '1' or M_4_tr = '1') and M_4 = '1' else
				  110 when (M4_5_tr = '1' or M3_5_tr = '1' or M2_5_tr = '1' or M_5_tr = '1') and M_5 = '1' else
				  110 when (M4_6_tr = '1' or M3_6_tr = '1' or M2_6_tr = '1' or M_6_tr = '1') and M_6 = '1' else
				  110 when (M4_7_tr = '1' or M3_7_tr = '1' or M2_7_tr = '1' or M_7_tr = '1') and M_7 = '1' else
				  110 when (H4_1_tr = '1' or H3_1_tr = '1' or H2_1_tr = '1' or H_1_tr = '1') and H_1 = '1' else
				  110 when (H4_2_tr = '1' or H3_2_tr = '1' or H2_2_tr = '1' or H_2_tr = '1') and H_2 = '1' else
				  110 when (H4_3_tr = '1' or H3_3_tr = '1' or H2_3_tr = '1' or H_3_tr = '1') and H_3 = '1' else
				  110 when (H4_4_tr = '1' or H3_4_tr = '1' or H2_4_tr = '1' or H_4_tr = '1') and H_4 = '1' else
				  110 when (H4_5_tr = '1' or H3_5_tr = '1' or H2_5_tr = '1' or H_5_tr = '1') and H_5 = '1' else
				  100;
	
	-- White-key display
	b0: bar_big port map(CounterX, CounterY, std_logic_vector(to_unsigned(0, 12)),
	std_logic_vector(to_unsigned(y_org, 12)), std_logic_vector(to_unsigned(white_x, 12)),
	std_logic_vector(to_unsigned(ydeta, 12)), white_bar);
	
	-- Blank key
	bar_blank1: bar_blank port map(CounterY, Hu4, Hu2, Hu1, Mu6,
	Mu5, Mu4, Mu2, Mu1, Lu6, Lu5, Lu4);
	
	by_org <= yd_t1 + 15 when Hu4 = '1' else
				 yd_t3 + 15 when Hu2 = '1' else
				 yd_t4 + 15 when Hu1 = '1' else
				 yd_t6 + 15 when Mu6 = '1' else
				 yd_t7 + 15 when Mu5 = '1' else
				 yd_t8 + 15 when Mu4 = '1' else
				 yd_t9 + 15 when Mu2 = '1' else
				 yd_t10 + 15 when Mu1 = '1' else
				 yd_t11 + 15 when Lu6 = '1' else
				 yd_t12 + 15 when Lu5 = '1' else
				 yd_t13 + 15 when Lu4 = '1' else
				 yd_t14 + 15;
	
	-- Blank-key play
	blank_x <= 60 when (L4u4_tr = '1' or L3u4_tr = '1' or L2u4_tr = '1' or Lu4_tr = '1') and Lu4 = '1' else
				  60 when (L4u5_tr = '1' or L3u5_tr = '1' or L2u5_tr = '1' or Lu5_tr = '1') and Lu5 = '1' else
				  60 when (L4u6_tr = '1' or L3u6_tr = '1' or L2u6_tr = '1' or Lu6_tr = '1') and Lu6 = '1' else
				  60 when (M4u1_tr = '1' or M3u1_tr = '1' or M2u1_tr = '1' or Mu1_tr = '1') and Mu1 = '1' else
				  60 when (M4u2_tr = '1' or M3u2_tr = '1' or M2u2_tr = '1' or Mu2_tr = '1') and Mu2 = '1' else
				  60 when (M4u4_tr = '1' or M3u4_tr = '1' or M2u4_tr = '1' or Mu4_tr = '1') and Mu4 = '1' else
				  60 when (M4u5_tr = '1' or M3u5_tr = '1' or M2u5_tr = '1' or Mu5_tr = '1') and Mu5 = '1' else
				  60 when (M4u6_tr = '1' or M3u6_tr = '1' or M2u6_tr = '1' or Mu6_tr = '1') and Mu6 = '1' else
				  60 when (H4u1_tr = '1' or H3u1_tr = '1' or H2u1_tr = '1' or Hu1_tr = '1') and Hu1 = '1' else
				  60 when (H4u2_tr = '1' or H3u2_tr = '1' or H2u2_tr = '1' or Hu2_tr = '1') and Hu2 = '1' else
				  60 when (H4u4_tr = '1' or H3u4_tr = '1' or H2u4_tr = '1' or Hu4_tr = '1') and Hu4 = '1' else
				  50;
	
	-- Blank-key display
	b2: bar_big port map(CounterX, CounterY, std_logic_vector(to_unsigned(0, 12)),
	std_logic_vector(to_unsigned(by_org, 12)), std_logic_vector(to_unsigned(blank_x, 12)),
	std_logic_vector(to_unsigned(ydeta, 12)), blank_bar);
	
	-- VGA data out
	inDisplayArea <= ida;
	vga_R <= (not blank_bar) and  white_bar and ida;
	vga_G <= (not blank_bar) and  white_bar and ida;
	vga_B <= (not blank_bar) and  white_bar and ida;
	
end staff_arch;