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
	signal n1,n			: std_logic_vector(9 downto 0);
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
	PROCESS(CLK)--Ïû³ý¶¶¶¯
	BEGIN
		IF CLK'EVENT AND CLK='1' THEN
			n<=n+1;
		END IF;
	END PROCESS;

	PROCESS(n(2),S1,S2)
	BEGIN
		IF n(2)'EVENT AND n(2)='1' THEN
			s1_buf<=S1;
			s2_buf<=S2;
		END IF;
	END PROCESS;
	
	process(clk1,rst)
	  variable sqt	: std_logic_vector(5 downto 0);
	begin
	  if rst='0' then
		sqt:=(others=>'0');
  	  elsif rising_edge(clk1) then
		  sqt:=sqt+1;
		  if sqt=60 then
		    sqt:=(others=>'0'); 
			secc<='1';
		  else
			secc<='0';
		  end if;
	  end if;
	  sq<=sqt;
	end process;
	
	process(sec,rst)
	  variable mqt	: std_logic_vector(5 downto 0);
	begin
	  if rst='0' then
		mqt:=(others=>'0');
  	  elsif rising_edge(sec) then
		  mqt:=mqt+1;
		  if mqt=60 then
		    mqt:=(others=>'0'); 
			minn<='1';
		  else
			minn<='0';
		  end if;
	  end if;
	  mq<=mqt;
	end process;
	
	process(min,rst)
	  variable hqt	: std_logic_vector(5 downto 0);
	begin
	  if rst='0' then
		hqt:=(others=>'0');
	  elsif rising_edge(min) then 
			hqt:=hqt+1;
		    if hqt=24 then
		    hqt:=(others=>'0');
			end if;
	  end if; 
	  hq<=hqt;
	end process;
	
	
	
	--calculate ADD sec&min
	process(secc,minn,s1_buf,s2_buf)
	  begin
		sec<=secc OR (NOT s1_buf);
		min<=minn OR (NOT s2_buf);	
	end process;
	
	--alarm
	process(mq,sq,clk,n1)
	  begin
		if mq=59 and sq>49 then
		  if clk='1' then
			spk<=n1(7);
		  else
		    spk<=n1(6);
		  end if;
		end if;
		-------
		if mq=59 and sq>54 then
		  --ledout<=conv_std_logic_vector(60-conv_integer(sq),4);
		  ledout(0)<=clk1;
		  ledout(1)<=clk1;
		  ledout(2)<=clk1;
		  ledout(3)<=clk1;
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
		when "111" => led<=conv_std_logic_vector(conv_integer(sq) rem 10,4);
		when "110" => led<=conv_std_logic_vector((conv_integer(sq)/10) rem 10,4);
		when "101" => led<="1111";
		when "100" => led<=conv_std_logic_vector(conv_integer(mq) rem 10,4);
		when "011" => led<=conv_std_logic_vector((conv_integer(mq)/10) rem 10,4);
		when "010" => led<="1111";
		when "001" => led<=conv_std_logic_vector(conv_integer(hq) rem 10,4);
		when "000" => led<=conv_std_logic_vector((conv_integer(hq)/10) rem 10,4);
	  end case; 
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
		    
		    
		    
		    
		    