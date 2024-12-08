library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity Account_Database_tb is
end entity Account_Database_tb;

architecture Behavioral of Account_Database_tb is
    -- Signals
    signal CLK         : STD_LOGIC;
    signal RST         : STD_LOGIC := '0';
    signal ADDRESS_IN  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal ACCOUNT_IN  : ACCOUNT := EmptyAccount;
    signal WRITE_EN    : STD_LOGIC := '0';
    signal ACCOUNT_OUT : ACCOUNT;

    -- Component under test
    component Account_Database
        generic (
            LENGTH : INTEGER := 32
        );
        port (
            CLK         : IN STD_LOGIC;
            RST         : IN STD_LOGIC;
            ADDRESS_IN  : IN STD_LOGIC_VECTOR(4 downto 0);
            ACCOUNT_IN  : IN ACCOUNT;
            WRITE_EN    : IN STD_LOGIC;
            ACCOUNT_OUT : OUT ACCOUNT
        );
    end component;

begin
    -- Instantiate Account_Database
    UUT: Account_Database
        port map (
            CLK         => CLK,
            RST         => RST,
            ADDRESS_IN  => ADDRESS_IN,
            ACCOUNT_IN  => ACCOUNT_IN,
            WRITE_EN    => WRITE_EN,
            ACCOUNT_OUT => ACCOUNT_OUT
        );

    -- Clock generation
    CLOCK_GEN: process
    begin
        CLK <= '0';
        wait for 10 ps;
        CLK <= '1';
        wait for 10 ps;
    end process;


    -- Stimulus
    stimulus: process
    begin
        -- RESET
        RST <= '1';
        wait for 20 ps;
        RST <= '0';

        -- Read from address 1
        ADDRESS_IN <= "00001";
        wait for 20 ps;
        
        -- Write to address 1
        ADDRESS_IN <= "00001";
        ACCOUNT_IN.PIN <= "0101";
        ACCOUNT_IN.MONEY <= "0000000000010000"; -- 16 units
        WRITE_EN <= '1';
        wait for 20 ps;
        WRITE_EN <= '0';

        -- Read from address 3
        ADDRESS_IN <= "00001";
        wait for 20 ps;

        -- Write to address 3
        ADDRESS_IN <= "00011";
        ACCOUNT_IN.PIN <= "0110";
        ACCOUNT_IN.MONEY <= "0000000000001000"; -- 8 units
        WRITE_EN <= '1';
        wait for 20 ps;
        WRITE_EN <= '0';

        -- Read from address 1
        ADDRESS_IN <= "00001";
        wait for 20 ps;

        -- Read from address 3
        ADDRESS_IN <= "00001";
        wait for 20 ps;

        -- Read from address 2
        ADDRESS_IN <= "00010";
        wait for 20 ps;

        -- End simulation
        wait;
    end process;

end architecture Behavioral;
