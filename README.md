# Sistem ATM Client-Server dengan Komunikasi SPI
GROUP PA08

Audy Natalie Cecilia R		2306266962

Laura	Fawzia Sambowo		2306260145

Muhammad Nadzhif Fikri		2306210102

Muhammad Pavel			2306243363

## Deskripsi Proyek

Proyek ini berfokus pada pengembangan dan optimasi sistem Automated Teller Machine (ATM) yang terhubung langsung ke server pusat melalui protokol Serial Peripheral Interface (SPI). Tujuan utamanya adalah meningkatkan kecepatan transaksi dan pengelolaan data, memberikan pengalaman transaksi perbankan yang lebih cepat dan lebih andal.

## Fitur Utama
1. **Pengelolaan Akun**: Setiap akun memiliki ID, PIN, dan saldo yang dapat diakses dan diperbarui.
2. **Operasi ATM**: Menyediakan dua opsi transaksi yaitu penarikan (withdraw) dan penyimpanan (store).
3. **Komunikasi SPI**: Menggunakan SPI untuk berkomunikasi antara ATM dan server.
4. **Finite State Machine (FSM)**: Untuk mengelola berbagai status transaksi.

## Komponen Sistem
1. **ATM Client**: 
   - Berkomunikasi dengan server menggunakan SPI (Slave).
   - Menangani interaksi pengguna dan mengirimkan permintaan transaksi.
   - Mengimplementasikan state machine untuk mengelola alur transaksi.

2. **Server**:
   - Berkomunikasi dengan ATM menggunakan SPI (Master).
   - Memproses transaksi secara simultan menggunakan circular queue.
   - Melakukan validasi akun, pembaruan saldo, dan pencatatan transaksi.

3. **Database Server**:
   - Menyimpan data akun termasuk ID akun, PIN, dan saldo.

4. **Koreksi Error**:
   - Kode Hamming diterapkan pada komunikasi SPI untuk memastikan transfer data yang andal antara ATM dan server.

5. **Manajemen Transaksi**:
   - Mendukung operasi seperti `LOGIN`, `WITHDRAW`, `STORE`, dan `LOGOUT` dengan umpan balik yang sesuai.

## Struktur Desain

Desain sistem ini terdiri dari beberapa komponen, masing-masing dengan fungsi khusus yang diterjemahkan dalam kode VHDL. Berikut adalah komponen-komponen utama yang ada dalam proyek ini:

### 1. **Account_Record (Package)**

Mengelola jenis data `Account` yang menyimpan informasi ID akun, PIN, ATM, dan saldo. 

#### Kode VHDL - `Account_Record`

```
package Account_Record is
    
    type Account is record
        ID : STD_LOGIC_VECTOR(4 downto 0);
        PIN : STD_LOGIC_VECTOR(3 downto 0);
        ATM : STD_LOGIC_VECTOR(2 downto 0);
        MONEY : STD_LOGIC_VECTOR(15 downto 0);
    end record;

    function EmptyAccount return Account;
end package Account_Record;
```

Jenis Desain: Dataflow Style

Penjelasan: Bagian ini mendefinisikan tipe data dan operasi untuk menangani informasi akun dalam bentuk record dan mendefinisikan fungsi untuk mengembalikan akun kosong (default).

2. Account_Database (Entity)
Database akun yang menyimpan informasi akun dalam array dan memungkinkan pembacaan atau penulisan data berdasarkan alamat yang diberikan.

Kode VHDL - Account_Database
```
architecture rtl of Account_Database is
    type Account_Array is array (0 to LENGTH - 1) of Account;
    SIGNAL Accounts : Account_Array := (others => EmptyAccount);

begin
    ACCOUNT_OUT <= Accounts(to_integer(unsigned(ADDRESS_IN)));
    PROCESS(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                -- Reset semua akun
                for i in 0 to LENGTH - 1 loop
                    Accounts(i).ID <= STD_LOGIC_VECTOR(to_unsigned(i, Accounts(i).ID'length));
                    Accounts(i).PIN <= (others => '0');
                    Accounts(i).ATM <= (others => '0');
                    Accounts(i).MONEY <= (others => '0');
                end loop;
            elsif WRITE_EN = '1' then
                Accounts(to_integer(unsigned(ADDRESS_IN))).PIN <= ACCOUNT_IN.PIN;
                Accounts(to_integer(unsigned(ADDRESS_IN))).ATM <= ACCOUNT_IN.ATM;
                Accounts(to_integer(unsigned(ADDRESS_IN))).MONEY <= ACCOUNT_IN.MONEY;
            end if;
        end if;
    end process;
end architecture rtl;
```
Jenis Desain: Dataflow Style

Penjelasan: Bagian ini menggunakan gaya Dataflow untuk mendefinisikan cara aliran data dalam database akun, termasuk pembacaan dan penulisan data akun berdasarkan alamat yang diberikan.

3. ATM_FSM (Finite State Machine)
FSM yang menangani logika kontrol untuk ATM, termasuk transaksi seperti penarikan atau penyimpanan dan proses login/logout.

Kode VHDL - ATM_FSM
```
architecture rtl of ATM_FSM is
    type StateType is (IDLE, INPUT, LOGOUT, SEND, WAIT_MESSAGE);
    SIGNAL STATE : StateType;

    SIGNAL MESSAGE_BUFFER : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    ALIAS OPCODE : STD_LOGIC_VECTOR(1 downto 0) is MESSAGE_BUFFER(15 downto 14);

begin
    TRANSITION : PROCESS(CLK)
        VARIABLE ACCOUNT_ACTIVE_ID : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    begin
        if rising_edge(CLK) and FSM_EN = '1' then
            case STATE is
                when IDLE =>
                    if INPUT_ID /= "00000" then
                        STATE <= INPUT;
                    elsif ACCOUNT_ACTIVE_ID /= "00000" then
                        STATE <= LOGOUT;
                    end if;

                when INPUT =>
                    if ACCOUNT_ACTIVE_ID = "00000" then
                        OPCODE <= "11";
                        ACCOUNT_ID <= INPUT_ID;
                        ACCOUNT_PIN <= INPUT_PIN;
                    else
                        if OPTION_WS = '0' then
                            OPCODE <= "01"; -- WITHDRAW
                        else
                            OPCODE <= "10"; -- STORE    
                        end if;
                    end if;
                    STATE <= SEND;

                when LOGOUT =>
                    OPCODE <= "00";
                    ACCOUNT_ID <= ACCOUNT_ACTIVE_ID;
                    STATE <= SEND;

                when SEND =>
                    MESSAGE_OUT <= MESSAGE_BUFFER;
                    MESSAGE_SEND <= '1';
                    STATE <= WAIT_MESSAGE;

                when WAIT_MESSAGE =>
                    MESSAGE_SEND <= '0';
                    if MESSAGE_IN(15) = '1' then
                        ACCOUNT_ACTIVE_ID := INPUT_ID;
                        CURRENT_BALANCE <= '0' & MESSAGE_IN(14 downto 0);
                    else
                        CURRENT_BALANCE <= (others => '0');
                    end if;
                    STATE <= IDLE;
            end case;
        end if;
    end process TRANSITION;
end architecture rtl;
```
Jenis Desain: FSM (Finite State Machine)

Penjelasan: Pada bagian ini, FSM digunakan untuk mengontrol transisi status dan proses yang terjadi pada ATM. Setiap status diwakili oleh enum (IDLE, INPUT, LOGOUT, dll), dan logika transisi terjadi dalam proses berbasis clock.

4. ATM (Top-Level Entity)
Komponen utama yang menggabungkan FSM dan SPI untuk menjalankan ATM secara keseluruhan. Bagian ini bertanggung jawab untuk menghubungkan berbagai subsistem.

Kode VHDL - ATM
```
architecture rtl of ATM is
    component ATM_FSM is
        port (
            CLK : IN STD_LOGIC;
            FSM_EN : IN STD_LOGIC;
            INPUT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
            INPUT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);
            INPUT_NOMINAL : IN STD_LOGIC_VECTOR(7 downto 0);
            OPTION_WS : IN STD_LOGIC;
            MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);
            MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
            MESSAGE_SEND : OUT STD_LOGIC;
            CURRENT_BALANCE : OUT STD_LOGIC_VECTOR(15 downto 0)
        );
    end component ATM_FSM;

    component SPI_Slave is
        port (
            SCK             => CLK,
            DATA_SEND       => MESSAGE_OUT_S,
            SEND_MESSAGE    => MESSAGE_SEND_S,
            LINE_BUSY       => LINE_BUSY,
            SDO             => SDO,
            SENDING         => SENDING_S,
            SLAVE_SELECT    => SLAVE_SELECT,
            SDI             => SDI,
            DATA_RECEIVE    => MESSAGE_IN_S,
            RECEIVED        => RECEIVED_S
        );
    end component SPI_Slave;
    
    FSM: ATM_FSM
    port map (
        CLK => CLK,
        FSM_EN => FSM_EN_S,
        INPUT_ID => INPUT_ID,
        INPUT_PIN => INPUT_PIN,
        INPUT_NOMINAL => INPUT_NOMINAL,
        OPTION_WS => OPTION_WS,
        MESSAGE_IN => MESSAGE_IN_S,
        MESSAGE_OUT => MESSAGE_OUT_S,
        MESSAGE_SEND => MESSAGE_SEND_S,
        CURRENT_BALANCE => CURRENT_BALANCE
    );

    SPI: SPI_Slave
    port map (
        SCK             => CLK,
        DATA_SEND       => MESSAGE_OUT_S,
        SEND_MESSAGE    => MESSAGE_SEND_S,
        LINE_BUSY       => LINE_BUSY,
        SDO             => SDO,
        SENDING         => SENDING_S,
        SLAVE_SELECT    => SLAVE_SELECT,
        SDI             => SDI,
        DATA_RECEIVE    => MESSAGE_IN_S,
        RECEIVED        => RECEIVED_S
    );
    
end architecture rtl;
```
Jenis Desain: Structural Style

Penjelasan: Desain ini menggunakan gaya Structural Style untuk menghubungkan berbagai komponen yang berbeda (FSM dan SPI) ke dalam sistem ATM secara keseluruhan. Setiap komponen dipasang secara eksplisit menggunakan port map.