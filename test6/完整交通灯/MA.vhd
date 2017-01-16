library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ma is 
port(rst,clk	:  in std_logic;
	del			:  out std_logic_vector(2 downto 0);
	ledag  		:  out std_logic_vector(6 downto 0); 
	traffic		:  out std_logic_vector(5 downto 0)
	);
end ma;
---------------------------------
architecture behav of ma is
  type states is (st0,st1,st2,st3,st4);
  signal st,next_st	: states;
  signal clk1,clk2  : std_logic;
  signal q	 		: std_logic_vector(5 downto 0);
  SIGNAL LEDg1,LEDg2,LED: STD_LOGIC_VECTOR(3 DOWNTO 0);
begin
  
  --freq division
  process(clk) --1khz
	  variable  n1	: std_logic_vector(9 downto 0);
	  variable  n2	: std_logic_vector(9 downto 0);
	begin
	    if clk'event and clk='1' then
		  if n1<499 then
			n1:=n1+1;
		  else
		    clk1<=not(clk1);
			n1:=(others=>'0');
		  end if;
		  if n2<249 then
			n2:=n2+1;
		  else
		    clk2<=not(clk2);
			n2:=(others=>'0');
		  end if;
		end if;  
	end process;
  
  --states display
  COM2:
  process(st)
  begin
    case st is
	when st1 => traffic<="001100";
	when st2 => traffic<="001000"; traffic(1)<=clk2;
	when st3 => traffic<="100001";
	when st4 => traffic<="000001"; traffic(4)<=clk2;
	when st0 => traffic<="111111";
    end case;
  end process;

  --states change
  COM1:
  process(st,q)
  begin
    case st is
	  when st0=> next_st<=st1;
	  when st1=> if(q<16) then next_st<=st1;
				else next_st<=st2; end if;
	  when st2=> if(q<19) then next_st<=st2;
				else next_st<=st3; end if;
	  when st3=> if(q<36) then next_st<=st3;
				else next_st<=st4; end if;
	  when st4=> if(q<39) then next_st<=st4;
				else next_st<=st1; end if;
	end case;
  end process;
  
  --states refresh
  REG:
  process(clk1,rst)
  begin
    if rst='0' then 
	  st<=st0;
	elsif rising_edge(clk1) then
	  st<=next_st;
	end if;
  end process;
	  
  --count time
  process(clk1,rst)
  begin
    if rst='0' then
	  q<=(others=>'0');
	elsif rising_edge(clk1) then
      if q<39 then
        q<=q+1;
      else
		q<=(others=>'0');
	  end if;
	end if;
  end process;
	  
  process(clk)
  begin
    if clk='1' then 
	  del<="001";
	  LED<=LEDg1;
	else 
	  del<="000";
	  LED<=LEDg2;
	end if;
  end process;
	  
  --time display
  process(q)
  begin
    if q<20 then
		LEDg1<=conv_std_logic_vector((19-(conv_integer(q))) rem 10,4);
		LEDg2<=conv_std_logic_vector(((19-(conv_integer(q)))/10) rem 10,4);
	else
		LEDg1<=conv_std_logic_vector((39-(conv_integer(q))) rem 10,4);
		LEDg2<=conv_std_logic_vector(((39-(conv_integer(q)))/10) rem 10,4);
	end if;
  end process;
  
  --bit to display 
  process(LED)
  begin
	  case LED is
		WHEN "0000" => ledag<="0111111";
		WHEN "0001" => ledag<="0000110";
		WHEN "0010" => ledag<="1011011";
		WHEN "0011" => ledag<="1001111";
		WHEN "0100" => ledag<="1100110";
		WHEN "0101" => ledag<="1101101";
		WHEN "0110" => ledag<="1111101";
		WHEN "0111" => ledag<="0000111";
		WHEN "1000" => ledag<="1111111";
		WHEN "1001" => ledag<="1101111";
		WHEN OTHERS => NULL;
	  end case;
  end process;
  
end;