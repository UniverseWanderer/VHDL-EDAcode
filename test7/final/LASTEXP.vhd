LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LASTEXP IS
PORT(CLK_10KHZ,S1,S2,S8:IN STD_LOGIC;
	 SPK:OUT STD_LOGIC;
	 LED14:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	 LEDAG:OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	 SEL:BUFFER STD_LOGIC_VECTOR(2 DOWNTO 0));
END ENTITY LASTEXP;

ARCHITECTURE BHV OF LASTEXP IS
TYPE STATE1 IS(S00,S11,S22,S33,S44,S55,S66);
SIGNAL C_STATE:STATE1;
SIGNAL CLK_1KHZ,CLK_1HZ,F1,F2,F3,F4,F5,S_1,S_2,OUT1,OUT2,CLK1,CLK2:STD_LOGIC;
SIGNAL SELQ:STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL LED,LEDQ1,LEDQ2,LEDQ3,LEDQ4,LEDQ5,LEDQ6:STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL SHI,FEN,MIAO:INTEGER;
SIGNAL DEVIDE:STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
PROCESS(CLK_10KHZ)--分频1秒
VARIABLE X:INTEGER:=0;
BEGIN
	IF CLK_10KHZ'EVENT AND CLK_10KHZ='1' THEN
		X:=X+1;
		IF X=5000 THEN
			CLK_1HZ<=NOT CLK_1HZ;
			X:=0;
		ELSE
			CLK_1HZ<=CLK_1HZ;
		END IF;
	END IF;
END PROCESS;

PROCESS(CLK_10KHZ)--扫描时钟1kHz
VARIABLE Y:INTEGER:=0;
BEGIN
	IF CLK_10KHZ'EVENT AND CLK_10KHZ='1' THEN
		Y:=Y+1;
		IF Y=5 THEN
			CLK_1KHZ<=NOT CLK_1KHZ;
			Y:=0;
		ELSE
			CLK_1KHZ<=CLK_1KHZ;
		END IF;
	END IF;
END PROCESS;
PROCESS(CLK_1KHZ)--消除抖动
BEGIN
	IF CLK_1KHZ'EVENT AND CLK_1KHZ='1' THEN
		DEVIDE<=DEVIDE+1;
	END IF;
END PROCESS;
PROCESS(DEVIDE(5),S1,S2)
BEGIN
	IF DEVIDE(5)'EVENT AND DEVIDE(5)='1' THEN
		S_1<=S1;
		S_2<=S2;
	END IF;
END PROCESS;

PROCESS(CLK_1HZ,S8)--秒计时
VARIABLE MIAO1:INTEGER RANGE 0 TO 60:=0;
BEGIN
	IF S8='0' THEN
		MIAO1:=0;
	ELSIF CLK_1HZ'EVENT AND CLK_1HZ='1' THEN
		MIAO1:=MIAO1+1;
		IF MIAO1=60 THEN
			MIAO1:=0;
			OUT1<='1';
		ELSE
			OUT1<='0';
		END IF;
	END IF;
	MIAO<=MIAO1;
END PROCESS;
PROCESS(OUT1,S_2)--S2调节
BEGIN
	CLK1<=OUT1 OR (NOT S_2);
END PROCESS;
PROCESS(CLK1,S8)--分计时
VARIABLE FEN1:INTEGER RANGE 0 TO 60:=0;
BEGIN
	IF S8='0' THEN
		FEN1:=0;
	ELSIF CLK1'EVENT AND CLK1='1' THEN
		FEN1:=FEN1+1;
		IF FEN1=60 THEN
			FEN1:=0;
			OUT2<='1';
		ELSE
			OUT2<='0';
		END IF;
	END IF;
	FEN<=FEN1;
END PROCESS;

PROCESS(OUT2,S_1)--S1调节
BEGIN
	CLK2<=OUT2 OR (NOT S_1);
END PROCESS;
PROCESS(CLK2,S8)--时计时
VARIABLE SHI1:INTEGER RANGE 0 TO 24:=0;
BEGIN
	IF S8='0' THEN
		SHI1:=0;
	ELSIF CLK2'EVENT AND CLK2='1' THEN
		SHI1:=SHI1+1;
		IF SHI1=24 THEN
			SHI1:=0;
		END IF;
	END IF;
	SHI<=SHI1;
END PROCESS;
PROCESS(CLK_10KHZ)--显示部分
VARIABLE SELQQ:STD_LOGIC_VECTOR(2 DOWNTO 0):="000";
BEGIN
	IF CLK_10KHZ'EVENT AND CLK_10KHZ='1' THEN
		SELQQ:=SELQQ+1;
	END IF;
	SELQ<=SELQQ;
	SEL<=SELQQ;
END PROCESS;
PROCESS(SHI,FEN,MIAO)
BEGIN
		LEDQ1 <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(SHI) REM 10),4);
		LEDQ2 <= CONV_STD_LOGIC_VECTOR(((CONV_INTEGER(SHI) / 10) REM 10),4);
		LEDQ3 <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(FEN) REM 10),4);
		LEDQ4 <= CONV_STD_LOGIC_VECTOR(((CONV_INTEGER(FEN) / 10) REM 10),4);
		LEDQ5 <= CONV_STD_LOGIC_VECTOR((CONV_INTEGER(MIAO) REM 10),4);
		LEDQ6 <= CONV_STD_LOGIC_VECTOR(((CONV_INTEGER(MIAO) / 10) REM 10),4);
END PROCESS;
PROCESS(SELQ)
BEGIN
	CASE SELQ IS
		WHEN "000"=>LED<=LEDQ2;
		WHEN "001"=>LED<=LEDQ1;
		WHEN "011"=>LED<=LEDQ4;
		WHEN "100"=>LED<=LEDQ3;
		WHEN "110"=>LED<=LEDQ6;
		WHEN "111"=>LED<=LEDQ5;
		WHEN OTHERS=>LED<="1111";
	END CASE;
END PROCESS;
PROCESS(LED)
BEGIN
	CASE LED IS
		WHEN  "0000" => LEDAG <="0111111";
        WHEN  "0001" => LEDAG <="0000110";
        WHEN  "0010" => LEDAG <="1011011";
        WHEN  "0011" => LEDAG <="1001111";
        WHEN  "0100" => LEDAG <="1100110";
        WHEN  "0101" => LEDAG <="1101101";
        WHEN  "0110" => LEDAG <="1111101";
        WHEN  "0111" => LEDAG <="0000111";
        WHEN  "1000" => LEDAG <="1111111";
        WHEN  "1001" => LEDAG <="1101111";
        WHEN  "1010" => LEDAG <="1110111";
        WHEN  "1011" => LEDAG <="1111100";
        WHEN  "1100" => LEDAG <="0111001";
        WHEN  "1101" => LEDAG <="1011110";
        WHEN  "1110" => LEDAG <="1111001";
        WHEN  "1111" => LEDAG <="1000000";
        WHEN  OTHERS => NULL;
	END CASE;
END PROCESS;
PROCESS(FEN,MIAO)--整点报时
BEGIN
	IF FEN=59 THEN
		CASE MIAO IS
			WHEN 50 =>F1<='1';F2<='0';F3<='0';F4<='0';F5<='0';
			WHEN 55 =>F1<='0';F2<='1';F3<='0';F4<='0';F5<='0';
			WHEN 56 =>F1<='0';F2<='0';F3<='1';F4<='0';F5<='0';
			WHEN 57 =>F1<='0';F2<='0';F3<='0';F4<='1';F5<='0';
			WHEN 58 =>F1<='0';F2<='0';F3<='0';F4<='0';F5<='1';
			WHEN 59 =>F1<='0';F2<='0';F3<='0';F4<='0';F5<='0';
			WHEN OTHERS=>F1<='0';F2<='0';F3<='0';F4<='0';F5<='0';
		END CASE;
	END IF;
END PROCESS;

PROCESS(C_STATE)--COM进程定义各状态
BEGIN
		CASE C_STATE IS
			WHEN S00=>
				SPK<='0';
				LED14<="0000";
			WHEN S11=>
				SPK<='0';
				LED14<="0000";
			WHEN S22=>
				SPK<=CLK_10KHZ;
				LED14<="0000";
			WHEN S33=>
				SPK<=CLK_10KHZ;
				LED14<="1000";
			WHEN S44=>
				SPK<=CLK_10KHZ;
				LED14<="0100";
			WHEN S55=>
				SPK<=CLK_10KHZ;
				LED14<="0010";
			WHEN S66=>
				SPK<=CLK_10KHZ;
				LED14<="0001";
			WHEN OTHERS=>
				SPK<='0';
				LED14<="0000";
		END CASE;
END PROCESS;
PROCESS(CLK_1HZ,C_STATE,F1,F2,F3,F4,F5,S8)--状态转换
BEGIN
	IF S8='0' THEN 
		C_STATE<=S00;
	ELSIF CLK_1HZ'EVENT AND CLK_1HZ='1' THEN
		CASE C_STATE IS
			WHEN S00=>
					C_STATE<=S11;
			WHEN S11=>
				IF F1='1' THEN 
					C_STATE<=S22;
				ELSE
					C_STATE<=S11;
				END IF;
			WHEN S22=>
			    IF F2='1' THEN
					C_STATE<=S33;
				ELSE
					C_STATE<=S22;
				END IF;
			WHEN S33=>
			    IF F3='1' THEN
					C_STATE<=S44;
				ELSE
					C_STATE<=S33;
				END IF;
			WHEN S44=>
				IF F4='1' THEN
					C_STATE<=S55;
				ELSE
					C_STATE<=S44;
				END IF;
			WHEN S55=>
			    IF F5='1' THEN
					C_STATE<=S66;
				ELSE
					C_STATE<=S55;
				END IF;
			WHEN S66=>
					C_STATE<=S11;
			WHEN OTHERS=>
					NULL;
		END CASE;
	END IF;
END PROCESS;
END ARCHITECTURE BHV;