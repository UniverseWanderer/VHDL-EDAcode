library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ma is
  port( 
	clk50m	: in std_logic;
	key		: in std_logic;
	clkin1	: in std_logic;
	clkin2	: in std_logic;	
	ledag  	: out  std_logic_vector(6 downto 0);  
	del    	: out  std_logic_vector(2 downto 0)
	);      
end ma;
------------------------------------------
architecture bhv of ma is

signal clkt		: std_logic;
signal clk1		: std_logic;
signal clk1k	: std_logic;
signal en		: std_logic;
signal clr		: std_logic;
signal load		: std_logic;
signal temp		: std_logic_vector(31 downto 0);
signal cout		: std_logic_vector(31 downto 0);
signal del_bak 	: std_logic_vector(2 downto 0);
SIGNAL SEG32	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL LEDg		: STD_LOGIC_VECTOR(3 DOWNTO 0);

begin
	--select test signal
	process(key)
	begin
	  if key='1' then
	    clkt<=clkin1;
	  else
	    clkt<=clkin2;
	  end if;
	end process;
	
	--freq division
	process(clk50m)
	  variable  q1	:  std_logic_vector(14 downto 0);
	  variable  q2	:  std_logic_vector(24 downto 0);
	begin
	    if clk50m'event and clk50m='1' then
		  if q1<24999 then
			q1:=q1+1;
		  else
		    clk1k<=not(clk1k);
			q1:=(others=>'0');
		  end if;
		  -------
		  if q2<24999999 then
			q2:=q2+1;
		  else
		    clk1<=not(clk1);
			q2:=(others=>'0');
		  end if;
		end if;
	end process;
	
	--control signal
	process(clk1)
	begin
	  if clk1'event and clk1='0' then
	    en<=not(en);	    
	  end if;
	  if load='1' and clk1='1' then
		clr<='1';
	  else
		clr<='0';
	  end if;
	  load<=not(en);
	end process;
	
	--count freq
	process(clkt,en,clr)
	  variable Q	: std_logic_vector(31 downto 0);
	begin
	  if clr='1' then 
	    Q:=(others=>'0');
	  elsif clkt'event and clkt='1' then
		  if en='1' then
			  Q:=Q+1;
		  end if;
	  end if;
	  temp<=Q;
	end process;
	
	--32bit storage
	process(load)
	begin
	  if load'event and load='1' then
		cout<=temp;
	  end if;	  
	end process;
	
	--LED DISPLAY
	--led scan
    process(clk1k) 
      variable  dount :  std_logic_vector(2 downto 0);   
    begin
        if clk1k'event and clk1k='1' then
            dount:=dount+1;
        end if;
         del<=dount;
         del_bak<=dount;
    end  process;
    --multi-LED display
    process(del_bak) 
    begin
      case del_bak is
		WHEN "111" => LEDg<=SEG32(31 DOWNTO 28);
		WHEN "110" => LEDg<=SEG32(27 DOWNTO 24);
		WHEN "101" => LEDg<=SEG32(23 DOWNTO 20);
		WHEN "100" => LEDg<=SEG32(19 DOWNTO 16);
		WHEN "011" => LEDg<=SEG32(15 DOWNTO 12);
		WHEN "010" => LEDg<=SEG32(11 DOWNTO 8);
		WHEN "001" => LEDg<=SEG32(7 DOWNTO 4);
		WHEN "000" => LEDg<=SEG32(3 DOWNTO 0);
	  end case;
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
    --counter to eight bit display
    process(cout)
	begin
		SEG32(31 DOWNTO 28) <= conv_std_logic_vector((conv_integer(cout) REM 10),4);
		SEG32(27 DOWNTO 24) <= conv_std_logic_vector(((conv_integer(cout) / 10) REM 10),4);
		SEG32(23 DOWNTO 20) <= conv_std_logic_vector(((conv_integer(cout) / 100) REM 10),4);
		SEG32(19 DOWNTO 16) <= conv_std_logic_vector(((conv_integer(cout) / 1000) REM 10),4);
		SEG32(15 DOWNTO 12) <= conv_std_logic_vector(((conv_integer(cout) / 10000) REM 10),4);
		SEG32(11 DOWNTO 8)  <= conv_std_logic_vector(((conv_integer(cout) / 100000) REM 10),4);
		SEG32(7 DOWNTO 4)   <= conv_std_logic_vector(((conv_integer(cout) / 1000000) REM 10),4);
		SEG32(3 DOWNTO 0)   <= conv_std_logic_vector(((conv_integer(cout) / 10000000) REM 10),4);
	end process;
   
end bhv;  
		
	    