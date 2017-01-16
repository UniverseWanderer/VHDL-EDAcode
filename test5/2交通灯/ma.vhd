library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ma is 
port(clk		:  in std_logic;
	ledag  		:  out std_logic_vector(6 downto 0); 
	traffic		:  out std_logic_vector(5 downto 0);
	del    		:  out  std_logic_vector(2 downto 0)
	);
end ma;
---------------------------------
architecture behav of ma is
  type states is (st0,st1,st2,st3,st4);
  signal st,next_st	: states;
  signal q	 		: std_logic_vector(4 downto 0);
  SIGNAL LEDg		: STD_LOGIC_VECTOR(3 DOWNTO 0);
begin

  --states display
  process(st)
  begin
    case st is
	when st1 => traffic<="001100";
	when st2 => traffic<="001010";
	when st3 => traffic<="100001";
	when st4 => traffic<="010001";
	when st0 => traffic<="111111";
    end case;
	del<="000";
  end process;

  --states change
  process(q)
  begin
    if q<6 then
	  next_st<=st1;
    elsif q<9 then
	  next_st<=st2;
    elsif q<15 then
	  next_st<=st3;
    elsif q<18 then
	  next_st<=st4;
    else
	  next_st<=st0;
    end if;
  end process;
     
  --states refresh
  process(clk)
  begin
    if rising_edge(clk) then
      if q<18 then
        q<=q+1;
        st<=next_st;
      else
        q<="00001";
        st<=st1; 
      end if;
    end if;
    if q<10 then
		LEDg<=conv_std_logic_vector(10-(conv_integer(q)),4);
	else 
		LEDg<=conv_std_logic_vector(19-(conv_integer(q)),4);
	end if;
  end process;

  --bit to display 
  process(LEDg)
  begin
	  case LEDg is
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