LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY ma IS
PORT(clk	: IN STD_LOGIC;
	 led	: OUT STD_LOGIC_VECTOR(7 downto 0)
	 );
END ma;

ARCHITECTURE bhv OF ma IS
	SIGNAL clk1		:	STD_LOGIC;
	SIGNAL con		:	STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL ledt		:	STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	--f division
	process(clk)
	  variable  f	:  std_logic_vector(9 downto 0);
	  begin
	    if rising_edge(clk) then
		  if f<499 then
			f:=f+1;
		  else
		    clk1<=not(clk1);
			f:=(others=>'0');
		  end if;
		end if;
	end process;
	
	--control signal
	process(clk1)
	  begin
		if rising_edge(clk1) then
		  con<=con+1;
		end if;
	end	process;
	
	--led change
	process(clk1,con)
	  begin
		if rising_edge(clk1) then
		  if con(3)='1' then
			ledt(7 downto 1)<=ledt(6 downto 0);
			ledt(0)<='1';
		  else
			ledt(6 downto 0)<=ledt(7 downto 1);
			ledt(7)<='0';
		  end if;
		end if;
		led<=ledt;
	end process;

END BHV;		