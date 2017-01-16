LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY ma IS
PORT(clk,ud : IN STD_LOGIC;
	 step	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	 del_1	: OUT std_logic_vector(2 downto 0);
	 temp	: out std_logic_vector(11 downto 0);
	 ledag	: OUT STD_LOGIC_VECTOR(6 downto 0)
	 );
END ma;

ARCHITECTURE bhv OF ma IS
	SIGNAL clk1		:	STD_LOGIC;
    signal dount 	:   std_logic_vector(2 downto 0); 
	signal led_1	:	std_logic_vector(15 downto 0);
	signal ledag_1  :  	std_logic_vector(27 downto 0);
	SIGNAL count	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
BEGIN
	--f division
	process(clk)
	  variable  f	:  std_logic_vector(9 downto 0);
	  begin
	    if clk'event and clk='1' then
		  if f<499 then
			f:=f+1;
		  else
		    clk1<=not(clk1);
			f:=(others=>'0');
		  end if;
		end if;
	end process;
	
	--led scan
    process(clk)   
      begin
        if clk'event and clk='1' then
			DOUNT<=DOUNT+1;
        end if;
		del_1<=dount;		
    end  process;
    
    --multi-LED display
    process(dount) 
      begin
      case  dount  is
          when  "111" => ledag <=ledag_1(6 downto 0);
          when  "110" => ledag <=ledag_1(13 downto 7);
          when  "101" => ledag <=ledag_1(20 downto 14);
          when  "100" => ledag <=ledag_1(27 downto 21);
          when  others => ledag <="0111111";
	  end  case;
	end  process;

	--add or sub
	process(clk1)
	  variable q	:  std_logic_vector(11 downto 0);
	  begin
	    if clk1'event and clk1='1' then
			if ud='1' then 	--add
				q:=q+step;
			else 			--sub
				q:=q-step;
			end if;
		end if;
		count<=q;
		temp<=count;
	end process;
	
	--display
	process(count)
	begin
		led_1(3 downto 0) <= conv_std_logic_vector((conv_integer(count) REM 10),4);
		led_1(7 downto 4) <= conv_std_logic_vector(((conv_integer(count) / 10) REM 10),4);
		led_1(11 downto 8) <= conv_std_logic_vector(((conv_integer(count) / 100) REM 10),4);
		led_1(15 downto 12) <= conv_std_logic_vector(((conv_integer(count) / 1000) REM 10),4);
	end process;
	--bit to display
ab:	for i in 0 to 3 generate
	begin
      process(led_1((i*4+3) downto (i*4))) 
      begin
      case  led_1((i*4+3) downto (i*4))  is
          when  "0000" => ledag_1((i*7+6) downto (i*7)) <="0111111";
          when  "0001" => ledag_1((i*7+6) downto (i*7)) <="0000110";
          when  "0010" => ledag_1((i*7+6) downto (i*7)) <="1011011";
          when  "0011" => ledag_1((i*7+6) downto (i*7)) <="1001111";
          when  "0100" => ledag_1((i*7+6) downto (i*7)) <="1100110";
          when  "0101" => ledag_1((i*7+6) downto (i*7)) <="1101101";
          when  "0110" => ledag_1((i*7+6) downto (i*7)) <="1111101";
          when  "0111" => ledag_1((i*7+6) downto (i*7)) <="0000111";
          when  "1000" => ledag_1((i*7+6) downto (i*7)) <="1111111";
          when  "1001" => ledag_1((i*7+6) downto (i*7)) <="1101111";
          when  "1010" => ledag_1((i*7+6) downto (i*7)) <="1110111";
          when  "1011" => ledag_1((i*7+6) downto (i*7)) <="1111100";
          when  "1100" => ledag_1((i*7+6) downto (i*7)) <="0111001";
          when  "1101" => ledag_1((i*7+6) downto (i*7)) <="1011110";
          when  "1110" => ledag_1((i*7+6) downto (i*7)) <="1111001";
          when  "1111" => ledag_1((i*7+6) downto (i*7)) <="1110001";
          when  others => null;
     end  case;
	 end  process;
   end generate;
   
end bhv;
