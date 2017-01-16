library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity EXP3 is
port (clk,rst,en 	: in  std_logic;
      dout 			: out std_logic_vector (3 downto 0);
      cout 			: out std_logic);
end EXP3;

architecture bhv of EXP3 is
	begin
	process(clk,rst,en)
		variable q :std_logic_vector(3 downto 0);
		begin 
		if rst='0' then q:=(others=>'0');
			elsif clk'event and clk='1' then
        		if en='1' then
         			if q<15 then 
						q:=q+1;
          			else q:=(others=>'0');
          			end if;
         		end if ;
        	end if;
     	if q="1011" then cout<='1';
      		else cout<='0'; 
		end if;
      	dout<=q;
    end process;
 end bhv;