library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_time_generator is
	port(
		pixel_clk: in std_logic;
		h_disp, h_fporch, h_sync, h_bporch,
		v_disp, v_fporch, v_sync, v_bporch: in std_logic_vector(11 downto 0);
		vga_hs, vga_vs, vga_blank: out std_logic;
		counterY, counterX: out std_logic_vector(11 downto 0)
	);
end vga_time_generator;

architecture vga_time_generator_arch of vga_time_generator is
	
	signal h_total, v_total: unsigned(11 downto 0);
	signal h_counter_reg, h_counter_next, v_counter_reg, v_counter_next: unsigned(11 downto 0);
	signal vga_hs_o_reg, vga_hs_o_next, vga_blank_hs_o_reg, vga_blank_hs_o_next, 
			 vga_vs_o_reg, vga_vs_o_next, vga_blank_vs_o_reg, vga_blank_vs_o_next: std_logic;
	signal counterX_reg, counterX_next, counterY_reg, counterY_next: unsigned(11 downto 0);
	
begin
	
	
	h_total <= unsigned(h_disp) + unsigned(h_fporch) + unsigned(h_sync) + unsigned(h_bporch);	
	
	process(pixel_clk)
	begin
		if(pixel_clk'event and pixel_clk = '1') then
			h_counter_reg <= h_counter_next;
		end if;
	end process;
	
	h_counter_next <= h_counter_reg + 1 when h_counter_reg < h_total - 1 else
							(others => '0');
	
	-- register logic for timing generator
	process(pixel_clk)
	begin
		if(pixel_clk'event and pixel_clk = '1') then
			vga_blank_hs_o_reg <= vga_blank_hs_o_next;
			vga_hs_o_reg <= vga_hs_o_next;
		end if;
	end process;
	
	vga_blank_hs_o_next <= '0' when h_counter_reg = 0 or h_counter_reg = unsigned(h_fporch) or
								  h_counter_reg = unsigned(h_fporch) + unsigned(h_sync) else
								  '1' when h_counter_reg = unsigned(h_fporch) + unsigned(h_sync) + unsigned(h_bporch) else
								  vga_blank_hs_o_reg;
									
	vga_hs_o_next <= '0' when h_counter_reg = unsigned(h_fporch) else
						  '1' when h_counter_reg = 0 or h_counter_reg = unsigned(h_fporch) + unsigned(h_sync) or
						  h_counter_reg = unsigned(h_fporch) + unsigned(h_sync) + unsigned(h_bporch) else
						  vga_hs_o_reg;
	
	v_total <= unsigned(v_disp) + unsigned(v_fporch) + unsigned(v_sync) + unsigned(v_bporch);	
	
	process(pixel_clk)
	begin
		if(pixel_clk'event and pixel_clk = '1') then
			v_counter_reg <= v_counter_next;
		end if;
	end process;
	
	v_counter_next <= v_counter_reg + 1 when v_counter_reg < v_total - 1 else
							(others => '0');
	
	-- register logic for timing generator
	process(pixel_clk)
	begin
		if(pixel_clk'event and pixel_clk = '1') then
			vga_blank_vs_o_reg <= vga_blank_vs_o_next;
			vga_vs_o_reg <= vga_vs_o_next;
		end if;
	end process;
	
	vga_blank_vs_o_next <= '0' when v_counter_reg = 0 or v_counter_reg = unsigned(v_fporch) or
								  v_counter_reg = unsigned(v_fporch) + unsigned(v_sync) else
								  '1' when v_counter_reg = unsigned(v_fporch) + unsigned(v_sync) + unsigned(v_bporch) else
								  vga_blank_vs_o_reg;
									
	vga_vs_o_next <= '0' when v_counter_reg = unsigned(v_fporch) else
						  '1' when v_counter_reg = 0 or v_counter_reg = unsigned(v_fporch) + unsigned(v_sync) or
						  v_counter_reg = unsigned(v_fporch) + unsigned(v_sync) + unsigned(v_bporch) else
						  vga_vs_o_reg;
	
	process(pixel_clk)
	begin
		if(pixel_clk'event and pixel_clk = '1') then
			counterX_reg <= counterX_next;
		end if;
	end process;
	
	counterX_next <= (others => '0') when vga_blank_hs_o_reg = '0' else
						  counterX_reg + 1;
	
	process(vga_hs_o_reg)
	begin
		if(vga_hs_o_reg'event and vga_hs_o_reg = '1') then
			counterY_reg <= counterY_next;
		end if;
	end process;
	
	counterY_next <= (others => '0') when vga_blank_vs_o_reg = '0' else
						  counterY_reg + 1;
	
	-- output logic
	vga_hs <= vga_hs_o_reg;
	vga_vs <= vga_vs_o_reg;
	vga_blank <= vga_blank_vs_o_reg and vga_blank_hs_o_reg;
	counterX <= std_logic_vector(counterX_reg);
	counterY <= std_logic_vector(counterY_reg);
	
end vga_time_generator_arch;