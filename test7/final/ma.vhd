library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ma is 
port(rst,clk,s1,s2	:  in std_logic;
	spk			:  out std_logic;
	sel			:  out std_logic_vector(2 downto 0);
	ledag  		:  out std_logic_vector(6 downto 0); 
	
	--clk1		:  in std_logic;
	--sqt,mqt,hqt	:  out std_logic_vector(5 downto 0);
	--ledt		:  out std_logic_vector(3 downto 0);
	--sect,mint	:  out std_logic;
	
	ledout		:  out std_logic_vector(3 downto 0)
	);
end ma;

architecture behav of ma is
	signal clk1			: std_logic;
	signal sec,min,secc,minn: std_logic;
	signal s1_buf,s2_buf: std_logic;
	signal sq,mq,hq		: std_logic_vector(5 downto 0);
	signal n1			: std_logic_vector(9 downto 0);
	signal del,del_temp	: std_logic_vector(2 downto 0);
	signal led			: std_logic_vector(3 downto 0);
begin
	--freq division
	process(clk) --1khz
	begin
	    if clk'event and clk='1' then
		  if n1<499 then
			n1<=n1+1;
		  else
		    clk1<=not(clk1);
			n1<=(others=>'0');
		  end if;
		end if;  
	end process;
	
	--shaking defend
    process(n1(5))  
      begin
        if n1(5)'event and n1(5)='1' then
            s1_buf<=s1;
            s2_buf<=s2;
        end if;
    end process;
	
	--count
	process(clk1,rst,sec,min)
	  begin
		if rst='0' then
		  sq<=(others=>'0');
		  mq<=(others=>'0');
		  hq<=(others=>'0');
		elsif rising_edge(clk1) then
		  if sq<60 then sq<=sq+1;
		    else sq<=(others=>'0'); end if;
		  if mq<60 then mq<=mq+sec;
		    else mq<=(others=>'0'); end if;
		  if hq<24 then hq<=hq+min;
		    else 
		    hq<=(others=>'0');
		    sq<=(others=>'0');
		    mq<=(others=>'0');
		  end if; 
		end if;
		
		--sqt<=sq;
		--mqt<=mq;
		--hqt<=hq;
		
	end process;
	
	--calculate ADD sec&min
	process(sq,mq,s1_buf,s2_buf)
	  begin
		if sq=59 then 
		  secc<='1';
		else
		  secc<='0';
		end if;
		if mq=59 and sq=59 then
		  minn<='1';
		else
		  minn<='0';
		end if;
		sec<=secc OR (NOT s1_buf);
		min<=minn OR (NOT s2_buf);
		
		--sect<=sec;
		--mint<=min;
		
	end process;
	
	--alarm
	process(mq,clk,n1)
	  begin
		if mq>50 then
		  if clk='1' then
			spk<=n1(4);
			--spk<='1';
		  else
		    spk<=n1(6);
		    --spk<='0';
		  end if;
		end if;
		-------
		if mq>54 then
		  ledout<=conv_std_logic_vector(60-conv_integer(mq),4);
		else
		  ledout<=(others=>'0');
		end if;
	end process;
	
	
	--display
	process(clk)
	begin
      if rising_edge(clk) then
		del<=del+1;
	  end if;
	  sel<=del;
	  del_temp<=del;
	end process;
	
	process(del_temp)
	begin
	  case del_temp is
		when "000" => led<=conv_std_logic_vector(conv_integer(sq) rem 10,4);
		when "001" => led<=conv_std_logic_vector((conv_integer(sq)/10) rem 10,4);
		when "010" => led<="1111";
		when "011" => led<=conv_std_logic_vector(conv_integer(mq) rem 10,4);
		when "100" => led<=conv_std_logic_vector((conv_integer(mq)/10) rem 10,4);
		when "101" => led<="1111";
		when "110" => led<=conv_std_logic_vector(conv_integer(hq) rem 10,4);
		when "111" => led<=conv_std_logic_vector((conv_integer(hq)/10) rem 10,4);
	  end case;
	  
	  --ledt<=led;
	  
	end process;
		
	process(led)
	begin
	  case led is
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
		WHEN "1111" => ledag<="1000000";
		WHEN OTHERS => NULL;
	  end case;
	end process;
		    
END;		    	    
		    
		    
		    
		    
		    
		    