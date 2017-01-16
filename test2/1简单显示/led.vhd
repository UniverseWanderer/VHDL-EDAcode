LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY led IS
  PORT(CLK   : IN  STD_LOGIC;
	   KEY   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
	   DEL   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	   LEDAG : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END;
ARCHITECTURE bhv OF led IS
  BEGIN
	PROCESS(CLK,KEY) 
		VARIABLE SEL : STD_LOGIC_VECTOR(2 DOWNTO 0);
	BEGIN
		CASE(KEY) IS
			WHEN "0000" => LEDAG<="0111111";
			WHEN "0001" => LEDAG<="0000110";
			WHEN "0010" => LEDAG<="1011011";
			WHEN "0011" => LEDAG<="1001111";
			WHEN "0100" => LEDAG<="1100110";
			WHEN "0101" => LEDAG<="1101101";
			WHEN "0110" => LEDAG<="1111101";
			WHEN "0111" => LEDAG<="0000111";
			WHEN "1000" => LEDAG<="1111111";
			WHEN "1001" => LEDAG<="1101111";
			WHEN "1010" => LEDAG<="1110111";
			WHEN "1011" => LEDAG<="1111100";
			WHEN "1100" => LEDAG<="0111001";
			WHEN "1101" => LEDAG<="1011110";
			WHEN "1110" => LEDAG<="1111001";
			WHEN "1111" => LEDAG<="1110001";
			WHEN OTHERS => NULL;
		END CASE;
		
		IF CLK'EVENT AND CLK='1' THEN
		    SEL:=SEL+1;		  
		END IF;
		DEL <= SEL;
		 	
	END PROCESS;
END;
