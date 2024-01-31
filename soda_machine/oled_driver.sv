// Author: Claude Garrett V
// File Description:
// An RTL driver for the OLEDrgb PMOD.

module oled_driver #(

  parameter  int   CLOCK_FREQUENCY        = 12000000,
  localparam  [4:0] BACKGROUND_COLOR_RED   = 5'b00000,
  localparam  [5:0] BACKGROUND_COLOR_GREEN = 6'b000000,
  localparam  [4:0] BACKGROUND_COLOR_BLUE  = 5'b00000,
  parameter  [4:0] TEXT_COLOR_RED         = 5'b11111,
  parameter  [5:0] TEXT_COLOR_GREEN       = 6'b111111,
  parameter  [4:0] TEXT_COLOR_BLUE        = 5'b11111,
  localparam [3:0] SPI_COMMAND_WAIT_COUNT = 4'b0100,
  localparam int   NUM_CHARACTERS         = 12,

  localparam int CHARACTER_WIDTH  = 8,
  localparam int CHARACTER_HEIGHT = 13

) (

  // System Signals:
  input clock,
  input reset_n,

  // SPI:
  output cs,     // Chip Select.
  output sck,    // Serial Clock. Minimum period of 150 ns, or 6.666... MHz.
  output mosi,   // Master Out Slave In. Shifted in from MSB to LSB, captured on each rising edge of sck.

  // OLED:
  output dc,              // Data/Command Control, 0 = command, 1 = data. Sampled on every 8th cycle of sck.
  output res,             // Power Reset.
  output vccen,           // VCC Enable.
  output pmoden,          // VDD Logic Voltage Enable.

  output init_done,       // Initialization is complete.
  output characters_done, // The characters have been displayed and we can accept new ones.

  // Character Interface:
  input [(NUM_CHARACTERS * 8) - 1:0] characters,
  input                              characters_valid

);

  typedef enum {
    COMMAND_SET_PINS,
    COMMAND_WAIT,
    COMMAND_SEND_BYTES,
    COMMAND_SERVE_USER
  } command_t;

  typedef logic [3:0] immediate_t;

  typedef struct packed {
    command_t   command;
    immediate_t immediate;
  } operation_t;

  // Pin Constants:
  localparam int PIN_DC     = 'b1000;
  localparam int PIN_RES    = 'b0100;
  localparam int PIN_VCCEN  = 'b0010;
  localparam int PIN_PMODEN = 'b0001;

  // Wait Constants:
  localparam int WAIT_3_US   = 0; localparam int COUNT_FOR_3_US   = CLOCK_FREQUENCY * 0.000003;
  localparam int WAIT_20_MS  = 1; localparam int COUNT_FOR_20_MS  = CLOCK_FREQUENCY * 0.020;
  localparam int WAIT_25_MS  = 2; localparam int COUNT_FOR_25_MS  = CLOCK_FREQUENCY * 0.025;
  localparam int WAIT_100_MS = 3; localparam int COUNT_FOR_100_MS = CLOCK_FREQUENCY * 0.1;
  localparam int WAIT_400_MS = 4; localparam int COUNT_FOR_400_MS = CLOCK_FREQUENCY * 0.4;

  localparam int NUM_OPERATIONS = 34;

  localparam operation_t [NUM_OPERATIONS:0] OPERATIONS = '{
    // 1.  dc = 0, res = 1, vccen = 0, pmoden = 1.
    0:'{command:COMMAND_SET_PINS, immediate:(PIN_RES | PIN_PMODEN)},

    // 2.  Wait 20 ms.
    1:'{command:COMMAND_WAIT, immediate:WAIT_20_MS},

    // 3.  res = 0.
    2:'{command:COMMAND_SET_PINS, immediate:(PIN_PMODEN)},

    // 4.  Wait 3 us.
    3:'{command:COMMAND_WAIT, immediate:WAIT_3_US},

    // 5   res = 1.
    4:'{command:COMMAND_SET_PINS, immediate:(PIN_RES | PIN_PMODEN)},

    // 6.  Wait for the reset operation to complete, which takes a maximum of 3 us (wait another 3 us?).
    5:'{command:COMMAND_WAIT, immediate:WAIT_3_US},

    // 7.  Enable the driver IC to accept commands by sending the unlock command over SPI (0xFD, 0x12). // In bits: 1111_1101, 0001_0010, should appear this way over SPI.
    6:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 8.  Send the display off command (0xAE). // In bits: 1010_1110.
    7:'{command:COMMAND_SEND_BYTES, immediate:1},

    // 9.  Set the Remap and Display formats (0xA0, 0x72).
    8:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 10. Set the Display Start Line to the top line (0xA2, 0x00).
    9:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 11. Set the Display Offset to No Vertical Offset (0xA2, 0x00).
    10:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 12. Make it a normal display with no color inversion or forcing the pixels on/off (0xA4).
    11:'{command:COMMAND_SEND_BYTES, immediate:1},

    // 13. Set the Multiplex Ratio to enable all of the common pins calculated by the 1+register value (0xA8, 0x3f).
    12:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 14. Set Master Configuration to use a required external VCC supply (0xAD, 0x8E).
    13:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 15. Disable Power Savings Mode (0xB0, 0x0B).
    14:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 16. Set the Phase Length of the charge and discharge rates of an OLED pixel in units of the display clock (0xB1, 0x31).
    15:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 17. Set the Display Clock Divide Ratio and Oscillator Frequency, setting the clock divider ratio to 1 and the internal oscillator frequency to ~890 kHz (0xB3, 0xF0).
    16:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 18. Set the Second Pre-Charge Speed of Color A to drive the color (defaults to red) to a target driving voltage (0x8A, 0x64).
    17:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 19. Set the Second Pre-Charge Speed of Color B to drive the color (defaults to green) to a target driving voltage (0x8B, 0x78).
    18:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 20. Set the Second Pre-Charge Speed of Color C to drive the color (defaults to blue) to a target driving voltage (0x8C, 0x64).
    19:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 21. Set the Pre-Charge Voltage to approximately 45% of VCC to drive each color to a target driving voltage (0xBB, 0x3A).
    20:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 22. Set the VCOMH Deselect Level, which is the minimum voltage level to be registered as logic high, to 83% of VCC (0xBE, 0x3E).
    21:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 23. Set Master Current Attenuation Factor to set a reference current for the segment drivers (0x87, 0x06).
    22:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 24. Set the Contrast for Color A (defaults to red) effectively setting the brightness level (0x81, 0x91).
    23:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 25. Set the Contrast for Color B (defaults to green) effectively setting the brightness level (0x82, 0x50).
    24:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 26. Set the Contrast for Color C (defaults to blue) effectively setting the brightness level (0x83, 0x7D).
    25:'{command:COMMAND_SEND_BYTES, immediate:2},

    // 27. Disable scrolling (0x2E).
    26:'{command:COMMAND_SEND_BYTES, immediate:1},

    // 28. Clear the screen by sending the clear command and the dimensions of the window to clear (top column, top row, bottom column, bottom rom) (0x25, 0x00, 0x00, 0x5F, 0x3F).
    27:'{command:COMMAND_SEND_BYTES, immediate:5},

    // 29. Bring vccen high.
    28:'{command:COMMAND_SET_PINS, immediate:(PIN_RES | PIN_VCCEN | PIN_PMODEN)},

    // 30. Wait 25 ms.
    29:'{command:COMMAND_WAIT, immediate:WAIT_25_MS},

    // 31. Turn on the display (0xAF).
    30:'{command:COMMAND_SEND_BYTES, immediate:1},

    // 32. Wait at least 100 ms before further operation.
    31:'{command:COMMAND_WAIT, immediate:WAIT_100_MS},

    // 33. Serve the User.
    32:'{command:COMMAND_SERVE_USER, immediate:0},

    // Shutting Down:

    // 1. Turn off the display (0xAE).
    33:'{command:COMMAND_SEND_BYTES, immediate:1},

    // 2. Bring vccen low.
    34:'{command:COMMAND_SET_PINS, immediate:(PIN_PMODEN)}

    // 3. Wait 400 MS. Skip since nothing happens afterwards.

  };

  localparam int NUM_SPI_BYTES = 45;

  localparam logic [NUM_SPI_BYTES:0] [7:0] SPI_BYTES = '{

    // 7.  Enable the driver IC to accept commands by sending the unlock command over SPI (0xFD, 0x12).
    0:'hFD, 1:'h12,

    // 8.  Send the display off command (0xAE).
    2:'hAE,

    // 9.  Set the Remap and Display formats (0xA0, 0x72).
    3:'hA0, 4:'h72,

    // 10. Set the Display Start Line to the top line (0xA1, 0x00).
    5:'hA1, 6:'h00,

    // 11. Set the Display Offset to No Vertical Offset (0xA2, 0x00).
    7:'hA2, 8:'h00,

    // 12. Make it a normal display with no color inversion or forcing the pixels on/off (0xA4).
    9:'hA4,

    // 13. Set the Multiplex Ratio to enable all of the common pins calculated by the 1+register value (0xA8, 0x3f).
    10:'hA8, 11:'h3F,

    // 14. Set Master Configuration to use a required external VCC supply (0xAD, 0x8E).
    12:'hAD, 13:'h8E,

    // 15. Disable Power Savings Mode (0xB0, 0x0B).
    14:'hB0, 15:'h0B,

    // 16. Set the Phase Length of the charge and discharge rates of an OLED pixel in units of the display clock (0xB1, 0x31).
    16:'hB1, 17:'h31,

    // 17. Set the Display Clock Divide Ratio and Oscillator Frequency, setting the clock divider ratio to 1 and the internal oscillator frequency to ~890 kHz (0xB3, 0xF0).
    18:'hB3, 19:'hF0,

    // 18. Set the Second Pre-Charge Speed of Color A to drive the color (defaults to red) to a target driving voltage (0x8A, 0x64).
    20:'h8A, 21:'h64,

    // 19. Set the Second Pre-Charge Speed of Color B to drive the color (defaults to green) to a target driving voltage (0x8B, 0x78).
    22:'h8B, 23:'h78,

    // 20. Set the Second Pre-Charge Speed of Color C to drive the color (defaults to blue) to a target driving voltage (0x8C, 0x64).
    24:'h8C, 25:'h64,

    // 21. Set the Pre-Charge Voltage to approximately 45% of VCC to drive each color to a target driving voltage (0xBB, 0x3A).
    26:'hBB, 27:'h3A,

    // 22. Set the VCOMH Deselect Level, which is the minimum voltage level to be registered as logic high, to 83% of VCC (0xBE, 0x3E).
    28:'hBE, 29:'h3E,

    // 23. Set Master Current Attenuation Factor to set a reference current for the segment drivers (0x87, 0x06).
    30:'h87, 31:'h06,

    // 24. Set the Contrast for Color A (defaults to red) effectively setting the brightness level (0x81, 0x91).
    32:'h81, 33:'h91,

    // 25. Set the Contrast for Color B (defaults to green) effectively setting the brightness level (0x82, 0x50).
    34:'h82, 35:'h50,

    // 26. Set the Contrast for Color C (defaults to blue) effectively setting the brightness level (0x83, 0x7D).
    36:'h83, 37:'h7D,

    // 27. Disable scrolling (0x2E).
    38:'h2E,

    // 28. Clear the screen by sending the clear command and the dimensions of the window to clear (top column, top row, bottom column, bottom rom) (0x25, 0x00, 0x00, 0x5F, 0x3F).
    39:'h25, 40:'h00, 41:'h00, 42:'h5F, 43:'h3F,

    // 30. Turn on the display (0xAF).
    44:'hAF,

    // Shutting Down:

    // 1. Turn off the display (0xAE).
    45:'hAF

  };

  typedef logic [CHARACTER_HEIGHT - 1:0] [CHARACTER_WIDTH - 1:0] character_t;

  localparam character_t [255:0] ASCII_TABLE = '{

    // !:
    8'h21:'{
      0:8'b00010000,
      1:8'b00010000,
      2:8'b00010000,
      3:8'b00010000,
      4:8'b00010000,
      5:8'b00000000,
      6:8'b00000000,
      7:8'b00010000,
      default:0
    },

    // $:
    8'h24:'{
      0:8'b00010000,
      1:8'b00111100,
      2:8'b01000100,
      3:8'b01000000,
      4:8'b00111000,
      5:8'b00000100,
      6:8'b01100100,
      7:8'b00011000,
      8:8'b00010000,
      default:0
    },

    // *:
    8'h2A:'{
      0:8'b00000000,
      1:8'b00010000,
      2:8'b01110100,
      3:8'b00011000,
      4:8'b00101000,
      5:8'b00000000,
      6:8'b00000000,
      7:8'b00000000,
      default:0
    },

    // .:
    8'h2E:'{
      0:8'b00000000,
      1:8'b00000000,
      2:8'b00000000,
      3:8'b00000000,
      4:8'b00000000,
      5:8'b00000000,
      6:8'b00010000,
      7:8'b00010000,
      default:0
    },

    // 0:
    8'h30:'{
      0:8'b01110000,
      1:8'b10001000,
      2:8'b10001000,
      3:8'b10001000,
      4:8'b10001000,
      5:8'b10001000,
      6:8'b10001000,
      7:8'b01110000,
      default:0
    },

    // 1:
    8'h31:'{
      0:8'b00000000,
      1:8'b01110000,
      2:8'b00010000,
      3:8'b00010000,
      4:8'b00010000,
      5:8'b00010000,
      6:8'b00010000,
      7:8'b01111100,
      default:0
    },

    // 2:
    8'h32:'{
      0:8'b00111000,
      1:8'b01000100,
      2:8'b00000100,
      3:8'b00001000,
      4:8'b00010000,
      5:8'b00010000,
      6:8'b00100000,
      7:8'b01111100,
      default:0
    },

    // 3:
    8'h33:'{
      0:8'b00111000,
      1:8'b00000100,
      2:8'b00000100,
      3:8'b00011000,
      4:8'b00000100,
      5:8'b00000100,
      6:8'b00000100,
      7:8'b00111000,
      default:0
    },

    // 4:
    8'h34:'{
      0:8'b00000000,
      1:8'b00001000,
      2:8'b00011000,
      3:8'b00101000,
      4:8'b01001000,
      5:8'b01111100,
      6:8'b00001000,
      7:8'b00011100,
      default:0
    },

    // 5:
    8'h35:'{
      0:8'b00111100,
      1:8'b01000000,
      2:8'b01011000,
      3:8'b00100100,
      4:8'b00000100,
      5:8'b00000100,
      6:8'b01000100,
      7:8'b00111000,
      default:0
    },

    // 6:
    8'h36:'{
      0:8'b00011100,
      1:8'b00100000,
      2:8'b00100000,
      3:8'b00111000,
      4:8'b00100100,
      5:8'b00100100,
      6:8'b00100100,
      7:8'b00011000,
      default:0
    },

    // 7:
    8'h37:'{
      0:8'b01111100,
      1:8'b00000100,
      2:8'b00001000,
      3:8'b00001000,
      4:8'b00001000,
      5:8'b00010000,
      6:8'b00010000,
      7:8'b00010000,
      default:0
    },

    // 8:
    8'h38:'{
      0:8'b00111000,
      1:8'b01000100,
      2:8'b01000100,
      3:8'b00111000,
      4:8'b01000100,
      5:8'b01000100,
      6:8'b01000100,
      7:8'b00111000,
      default:0
    },

    // 9:
    8'h39:'{
      0:8'b00111000,
      1:8'b00100100,
      2:8'b00100100,
      3:8'b00100100,
      4:8'b00111100,
      5:8'b00000100,
      6:8'b00001000,
      7:8'b00110000,
      default:0
    },

    // ::
    8'h3A:'{
      0:8'b00000000,
      1:8'b00010000,
      2:8'b00010000,
      3:8'b00000000,
      4:8'b00000000,
      5:8'b00000000,
      6:8'b00010000,
      7:8'b00010000,
      default:0
    },

    // A:
    8'h41:'{
      0:8'b00000000,
      1:8'b01110000,
      2:8'b00101000,
      3:8'b00101000,
      4:8'b01001000,
      5:8'b01111100,
      6:8'b01000100,
      7:8'b11100110,
      default:0
    },

    // 'B':
    8'h42:'{
      0:8'b00000000,
      1:8'b01111000,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b01111100,
      5:8'b01000100,
      6:8'b01000100,
      7:8'b01111000,
      default:0
    },

    // 'C':
    8'h43:'{
      0:8'b00000000,
      1:8'b00111000,
      2:8'b01000100,
      3:8'b01000000,
      4:8'b01000000,
      5:8'b01000000,
      6:8'b01000100,
      7:8'b00111000,
      default:0
    },

    // 'D':
    8'h44:'{
      0:8'b00000000,
      1:8'b01111000,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b01000100,
      5:8'b01000100,
      6:8'b01000100,
      7:8'b01111000,
      default:0
    },

    // 'E':
    8'h45:'{
      0:8'b00000000,
      1:8'b01111100,
      2:8'b01000100,
      3:8'b01000000,
      4:8'b01110000,
      5:8'b01000000,
      6:8'b01000100,
      7:8'b01111100,
      default:0
    },

    // 'F':
    8'h46:'{
      0:8'b00000000,
      1:8'b01111100,
      2:8'b01000100,
      3:8'b01000000,
      4:8'b01110000,
      5:8'b01000000,
      6:8'b01000000,
      7:8'b01000000,
      default:0
    },

    // 'G':
    8'h47:'{
      0:8'b00000000,
      1:8'b00111100,
      2:8'b01000100,
      3:8'b01000000,
      4:8'b01000000,
      5:8'b01001110,
      6:8'b01000100,
      7:8'b00111100,
      default:0
    },

    // 'H':
    8'h48:'{
      0:8'b00000000,
      1:8'b01101100,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b01111100,
      5:8'b01000100,
      6:8'b01000100,
      7:8'b01101110,
      default:0
    },

    // 'I':
    8'h49:'{
      0:8'b00000000,
      1:8'b01111100,
      2:8'b00010000,
      3:8'b00010000,
      4:8'b00010000,
      5:8'b00010000,
      6:8'b00010000,
      7:8'b01111100,
      default:0
    },

    // 'J':
    8'h4A:'{
      0:8'b00000000,
      1:8'b00011110,
      2:8'b00000100,
      3:8'b00000100,
      4:8'b00000100,
      5:8'b01000100,
      6:8'b01001000,
      7:8'b00111000,
      default:0
    },

    // 'K':
    8'h4B:'{
      0:8'b00000000,
      1:8'b01101110,
      2:8'b01001000,
      3:8'b01010000,
      4:8'b01110000,
      5:8'b01001000,
      6:8'b01000100,
      7:8'b01100110,
      default:0
    },

    // 'L':
    8'h4C:'{
      0:8'b00000000,
      1:8'b01110000,
      2:8'b00100000,
      3:8'b00100000,
      4:8'b00100000,
      5:8'b00100010,
      6:8'b00100010,
      7:8'b01111110,
      default:0
    },

    // 'M':
    8'h4D:'{
      0:8'b00000000,
      1:8'b01100011,
      2:8'b01010110,
      3:8'b01010110,
      4:8'b01001010,
      5:8'b01000010,
      6:8'b01100011,
      7:8'b00000000,
      default:0
    },

    // 'N':
    8'h4E:'{
      0:8'b00000000,
      1:8'b01100111,
      2:8'b00110010,
      3:8'b00110010,
      4:8'b00101010,
      5:8'b00100110,
      6:8'b00100110,
      7:8'b00110010,
      default:0
    },

    // 'O':
    8'h4F:'{
      0:8'b00000000,
      1:8'b00111000,
      2:8'b01000100,
      3:8'b01000010,
      4:8'b01000010,
      5:8'b01000010,
      6:8'b01000100,
      7:8'b00111000,
      default:0
    },

    // 'P':
    8'h50:'{
      0:8'b00000000,
      1:8'b01111000,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b01111000,
      5:8'b01000000,
      6:8'b01000000,
      7:8'b01110000,
      default:0
    },

    // 'Q':
    8'h51:'{
      0:8'b00000000,
      1:8'b00111000,
      2:8'b01000100,
      3:8'b01000010,
      4:8'b01000010,
      5:8'b01000010,
      6:8'b01000100,
      7:8'b00101000,
      8:8'b00110000,
      9:8'b00001100,
      default:0
    },

    // 'R':
    8'h52:'{
      0:8'b00000000,
      1:8'b01111000,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b01111000,
      5:8'b01001000,
      6:8'b01000100,
      7:8'b01100010,
      default:0
    },

    // 'S':
    8'h53:'{
      0:8'b00000000,
      1:8'b00111100,
      2:8'b01000100,
      3:8'b01000000,
      4:8'b00111000,
      5:8'b00000100,
      6:8'b01000100,
      7:8'b01111000,
      default:0
    },

    // 'T':
    8'h54:'{
      0:8'b00000000,
      1:8'b01111100,
      2:8'b00010000,
      3:8'b00010000,
      4:8'b00010000,
      5:8'b00010000,
      6:8'b00010000,
      7:8'b00111000,
      default:0
    },

    // 'U':
    8'h55:'{
      0:8'b00000000,
      1:8'b11101110,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b01000100,
      5:8'b01000100,
      6:8'b01000100,
      7:8'b00111000,
      default:0
    },

    // 'V':
    8'h56:'{
      0:8'b00000000,
      1:8'b11100110,
      2:8'b01000100,
      3:8'b01000100,
      4:8'b00101000,
      5:8'b00101000,
      6:8'b00101000,
      7:8'b00010000,
      default:0
    },

    // 'W':
    8'h57:'{
      0:8'b00000000,
      1:8'b11110111,
      2:8'b00100010,
      3:8'b00101010,
      4:8'b00110110,
      5:8'b00110110,
      6:8'b00110110,
      7:8'b00100010,
      default:0
    },

    // 'X':
    8'h58:'{
      0:8'b00000000,
      1:8'b01100110,
      2:8'b00101000,
      3:8'b00101000,
      4:8'b00010000,
      5:8'b00101000,
      6:8'b01000100,
      7:8'b11101110,
      default:0
    },

    // 'Y':
    8'h59:'{
      0:8'b00000000,
      1:8'b01100110,
      2:8'b01001000,
      3:8'b00101000,
      4:8'b00010000,
      5:8'b00010000,
      6:8'b00010000,
      7:8'b00111000,
      default:0
    },

    // 'Z':
    8'h5A:'{
      0:8'b00000000,
      1:8'b01111100,
      2:8'b01001000,
      3:8'b00001000,
      4:8'b00010000,
      5:8'b00100100,
      6:8'b01000100,
      7:8'b01111100,
      default:0
    },

    default:0

  };

  localparam int NUM_CLEAR_SCREEN_BYTES = 5;
  // 28. Clear the screen by sending the clear command and the dimensions of the window to clear (top column, top row, bottom column, bottom rom) (0x25, 0x00, 0x00, 0x5F, 0x3F).
  localparam logic [NUM_CLEAR_SCREEN_BYTES:0] [7:0] CLEAR_SCREEN_BYTES = '{
    0:8'h25,
    1:8'h00,
    2:8'h00,
    3:8'h5F,
    4:8'h3F,
    default:0
  };

  localparam logic [NUM_CHARACTERS - 1:0] [7:0] RESET_MESSAGE_CHARS = "READY!      ";

  // State Variables:
  typedef struct packed {

    // Internal State Variables:
    logic [5:0]  command_pointer;  // Pointer to the current command.
    logic [31:0] wait_counter;     // Number of cycles we have waited.
    logic [5:0]  spi_byte_pointer; // Pointer to the current SPI command byte.
    logic [7:0]  spi_byte;         // The current SPI byte that we are sending.
    logic [3:0]  spi_bytes_sent;   // Number of bytes sent for this command.
    logic        spi_bytes_done;   // Are we done sending the required SPI bytes for this command?
    logic [2:0]  spi_bit_pointer;  // Pointer to the bit we are sending from spi_byte.
    logic        spi_bit_valid;    // Should we send the bit pointer to by spi_bit_pointer?
    logic        spi_data_command; // Is this data or a command? 0 = Command, 1 = Data.

    // Serve User:
    logic                              captured_characters;   // Have we captured the current characters to display?
    logic [NUM_CHARACTERS - 1:0] [7:0] characters;            // The captured characters to write to the screen.
    logic                              sent_reset_message;    // Have we sent the reset message?
    logic                              screen_cleared;        // Has the screen been cleared yet?
    logic [3:0]                        characters_written;    // How many characters have been written to the screen?
    logic [2:0]                        pixels_sent;           // How many pixels have we sent?
    logic [3:0]                        lines_sent;            // How many lines have we sent?
    logic                              sent_characters;       // Are we done sending characters?
    logic [2:0]                        spi_user_byte_pointer; // Pointer for use in the server user command.
    logic                              update_column_addr;    // Do we need to update the column address?
    logic [6:0]                        column_addr;           // The current column address.
    logic                              update_row_addr;       // Do we need to update the row address?
    logic [5:0]                        row_addr;              // The current column address.

    // SPI Outputs:
    logic cs;
    logic sck;
    logic mosi;

    // PMOD Outputs:
    logic dc;
    logic res;
    logic vccen;
    logic pmoden;
    logic init_done;

  } state_t;

  state_t current_state, next_state;

  always @(posedge clock) current_state = next_state;

  // SPI Output Assignments:
  assign cs   = current_state.cs;
  assign sck  = current_state.sck;
  assign mosi = current_state.mosi;

  // PMOD Output Assignments:
  assign dc              = current_state.dc;
  assign res             = current_state.res;
  assign vccen           = current_state.vccen;
  assign pmoden          = current_state.pmoden;

  assign init_done       = current_state.init_done;
  assign characters_done = ~current_state.captured_characters;

  // Temporary Aliasing Variables:
  operation_t temp_current_operation;

  character_t temp_char;

  always_comb begin

    // Defaults:
    next_state = current_state;

    temp_current_operation = OPERATIONS[current_state.command_pointer];

    case(temp_current_operation.command)

      COMMAND_SET_PINS: begin

        // Apply our new pin settings.
        {next_state.dc, next_state.res, next_state.vccen, next_state.pmoden} = temp_current_operation.immediate;

        // Go to the next command.
        next_state.command_pointer = current_state.command_pointer + 1;

      end

      COMMAND_WAIT: begin

        case(temp_current_operation.immediate)

          WAIT_3_US: begin
            if(current_state.wait_counter == COUNT_FOR_3_US) begin
              next_state.wait_counter    = '0;
              next_state.command_pointer = current_state.command_pointer + 1;
            end
            
            else next_state.wait_counter = current_state.wait_counter + 1;
          end

          WAIT_20_MS: begin
            if(current_state.wait_counter == COUNT_FOR_20_MS) begin
              next_state.wait_counter    = '0;
              next_state.command_pointer = current_state.command_pointer + 1;
            end
            
            else next_state.wait_counter = current_state.wait_counter + 1;
          end

          WAIT_25_MS: begin
            if(current_state.wait_counter == COUNT_FOR_25_MS) begin
              next_state.wait_counter    = '0;
              next_state.command_pointer = current_state.command_pointer + 1;
            end
            
            else next_state.wait_counter = current_state.wait_counter + 1;
          end

          WAIT_100_MS: begin
            if(current_state.wait_counter == COUNT_FOR_100_MS) begin
              next_state.wait_counter    = '0;
              next_state.command_pointer = current_state.command_pointer + 1;
            end
            
            else next_state.wait_counter = current_state.wait_counter + 1;
          end

          WAIT_400_MS: begin
            if(current_state.wait_counter == COUNT_FOR_400_MS) begin
              next_state.wait_counter    = '0;
              next_state.command_pointer = current_state.command_pointer + 1;
            end
            
            else next_state.wait_counter = current_state.wait_counter + 1;
          end

        endcase

      end

      COMMAND_SEND_BYTES: begin

        next_state.spi_byte = SPI_BYTES[current_state.spi_byte_pointer];
        next_state.spi_data_command = '0; // We are sending a command.

        // If we are done, wait a bit before starting the next transaction.
        if(current_state.spi_bytes_done) begin

          if(current_state.wait_counter == SPI_COMMAND_WAIT_COUNT) begin
            next_state.wait_counter    = '0;
            next_state.command_pointer = current_state.command_pointer + 1;
            next_state.spi_bytes_done  = '0;
          end

          // If not, increment and keep waiting.
          else next_state.wait_counter = current_state.wait_counter + 1;

        end

        // See if we did a transfer.
        else if(~current_state.cs & current_state.sck) begin

          // See if we have finished sending this byte.
          if(current_state.spi_bit_pointer == '1) begin
            next_state.spi_byte_pointer = current_state.spi_byte_pointer + 1;     // Point to the next SPI byte.
            next_state.spi_byte         = SPI_BYTES[next_state.spi_byte_pointer]; // Get the next byte to send.
            next_state.spi_bytes_sent   = current_state.spi_bytes_sent + 1;       // We have sent another byte.
            next_state.spi_bit_pointer  = '0;                                     // Point to the first bit of the new byte.
          end

          // Otherwise, increment spi_bit_pointer.
          else begin
            next_state.spi_bit_pointer = current_state.spi_bit_pointer + 1;
          end
          
          // See if we are done.
          if(next_state.spi_bytes_sent == temp_current_operation.immediate) begin

            next_state.spi_bytes_done = '1; // We are done with this SPI command.
            next_state.spi_bit_valid  = '0; // We no longer need to send SPI data.
            next_state.spi_bytes_sent = '0; // Reset for the next command.

          end

        end

        // Mark our current data as valid.
        else begin

          next_state.spi_bit_valid = '1;

        end

      end

      COMMAND_SERVE_USER: begin

        // If we are here, we are done with initialization.
        next_state.init_done = '1;

        // Print the reset message.
        if(~current_state.sent_reset_message & ~current_state.captured_characters) begin

          // Copy the reset message.
          next_state.characters          = RESET_MESSAGE_CHARS;
          next_state.captured_characters = '1;
          next_state.sent_reset_message  = '1;

        end

        // Capture the input characters.
        if(characters_valid & ~current_state.captured_characters) begin

          // Capture the input characters.
          next_state.characters          = characters;
          next_state.captured_characters = '1;
          next_state.sent_characters     = '0;

        end

        // Clear the screen.
        if(next_state.captured_characters & ~current_state.screen_cleared) begin

          next_state.spi_byte = CLEAR_SCREEN_BYTES[current_state.spi_user_byte_pointer];
          next_state.spi_data_command = '0; // We are sending a command.

          // If we are done, wait a bit before starting the next transaction.
          if(current_state.spi_bytes_done) begin

            if(current_state.wait_counter == SPI_COMMAND_WAIT_COUNT) begin
              next_state.wait_counter          = '0;
              next_state.spi_bytes_done        = '0;
              next_state.spi_user_byte_pointer = '0;
              next_state.screen_cleared        = '1; // We have finished clearing the screen.
            end

            // If not, increment and keep waiting.
            else next_state.wait_counter = current_state.wait_counter + 1;

          end

          // See if we did a transfer.
          else if(~current_state.cs & current_state.sck) begin

            // See if we have finished sending this byte.
            if(current_state.spi_bit_pointer == '1) begin
              next_state.spi_user_byte_pointer = current_state.spi_user_byte_pointer + 1;              // Point to the next SPI byte.
              next_state.spi_byte              = CLEAR_SCREEN_BYTES[next_state.spi_user_byte_pointer]; // Get the next byte to send.
              next_state.spi_bytes_sent        = current_state.spi_bytes_sent + 1;                     // We have sent another byte.
              next_state.spi_bit_pointer       = '0;                                                   // Point to the first bit of the new byte.
            end

            // Otherwise, increment spi_bit_pointer.
            else begin
              next_state.spi_bit_pointer = current_state.spi_bit_pointer + 1;
            end
            
            // See if we are done.
            if(next_state.spi_bytes_sent == NUM_CLEAR_SCREEN_BYTES) begin

              next_state.spi_bytes_done = '1; // We are done with this SPI command.
              next_state.spi_bit_valid  = '0; // We no longer need to send SPI data.
              next_state.spi_bytes_sent = '0; // Reset for the next command.

            end

          end

          // Mark our current SPI data as valid.
          else begin

            next_state.spi_bit_valid = '1;

          end

        end

        // Send the characters.
        if(current_state.screen_cleared & ~current_state.sent_characters) begin

          // Update the column address.
          if(~current_state.update_column_addr) begin

            next_state.spi_data_command = '0; // We are sending a command.

            // Pick the byte to send.
            case(current_state.spi_bytes_sent)
              0: next_state.spi_byte = 8'h15;                                           // The command to update the addresses.
              1: next_state.spi_byte = current_state.column_addr;                       // Column starting address.
              2: next_state.spi_byte = current_state.column_addr + CHARACTER_WIDTH - 1; // Column ending address.
            endcase

          end

          // Update the row address.
          else if(~current_state.update_row_addr) begin

            next_state.spi_data_command = '0; // We are sending a command.

            // Pick the byte to send.
            case(current_state.spi_bytes_sent)
              0: next_state.spi_byte = 8'h75;                                         // The command to update the addresses.
              1: next_state.spi_byte = current_state.row_addr;                        // Row starting address.
              2: next_state.spi_byte = current_state.row_addr + CHARACTER_HEIGHT - 1; // Row ending address.
            endcase

          end

          // Send the character data.
          else begin

            next_state.spi_data_command = '1; // We are sending data.
            
            temp_char = ASCII_TABLE[next_state.characters[NUM_CHARACTERS - 1 - next_state.characters_written]];
            
            if(current_state.spi_bytes_sent % 2 == 0) begin
              next_state.spi_byte = (temp_char[next_state.lines_sent][7 - next_state.pixels_sent] == '1) ? {TEXT_COLOR_BLUE, TEXT_COLOR_GREEN, TEXT_COLOR_RED} >> 8 : {BACKGROUND_COLOR_BLUE, BACKGROUND_COLOR_GREEN, BACKGROUND_COLOR_RED} >> 8;
            end

            else begin
              next_state.spi_byte = (temp_char[next_state.lines_sent][7 - next_state.pixels_sent] == '1) ? {TEXT_COLOR_BLUE, TEXT_COLOR_GREEN, TEXT_COLOR_RED} & 'hFF : {BACKGROUND_COLOR_BLUE, BACKGROUND_COLOR_GREEN, BACKGROUND_COLOR_RED} & 'hFF;
            end

          end

          // If we are done, wait a bit before starting the next transaction.
          if(current_state.spi_bytes_done) begin

            if(current_state.wait_counter == SPI_COMMAND_WAIT_COUNT) begin

              // See if we are done with this line of text.
              if(current_state.characters_written == NUM_CHARACTERS) begin

                // Prepare for the next input.
                next_state.screen_cleared      = '0;

                next_state.update_column_addr  = '0;
                next_state.column_addr         = '0;
                next_state.update_row_addr     = '0;
                next_state.row_addr            = '0;

                next_state.characters_written  = '0;
                next_state.lines_sent          = '0;
                next_state.pixels_sent         = '0;

                next_state.captured_characters = '0;

                next_state.sent_characters     = '1;

              end

              // Otherwise, we have more characters to send.
              else if(current_state.update_column_addr & current_state.update_row_addr) begin

                // See of we are done with this line.
                if(next_state.pixels_sent == CHARACTER_WIDTH - 1) begin

                  next_state.pixels_sent = '0;

                  // See if we are done with this character.
                  if(next_state.lines_sent == CHARACTER_HEIGHT - 1) begin

                    // Increment the character counter and reset all of the column/row address stuff.
                    next_state.characters_written = current_state.characters_written + 1;
                    next_state.update_column_addr = '0;
                    next_state.column_addr        = current_state.column_addr + CHARACTER_WIDTH;
                    next_state.update_row_addr    = '0;
                    // next_state.row_addr           = current_state.row_addr + CHARACTER_HEIGHT;
                    next_state.lines_sent         = '0;

                  end

                  // Otherwise, increment the line count.
                  else next_state.lines_sent = current_state.lines_sent + 1;

                end

                // Otherwise, increment the pixel count.
                else next_state.pixels_sent = current_state.pixels_sent + 1;

              end

              // Mark address updates as done.
              if(~current_state.update_column_addr) next_state.update_column_addr = '1;
              else if(~current_state.update_row_addr) next_state.update_row_addr  = '1;

              next_state.wait_counter          = '0;
              next_state.spi_bytes_done        = '0;

            end

            // If not, increment and keep waiting.
            else next_state.wait_counter = current_state.wait_counter + 1;

          end

          // See if we did a transfer.
          else if(~current_state.cs & current_state.sck) begin

            // See if we have finished sending this byte.
            if(current_state.spi_bit_pointer == '1) begin

              next_state.spi_bytes_sent        = current_state.spi_bytes_sent + 1;                     // We have sent another byte.
              next_state.spi_bit_pointer       = '0;                                                   // Point to the first bit of the new byte.
            end

            // Otherwise, increment spi_bit_pointer.
            else begin
              next_state.spi_bit_pointer = current_state.spi_bit_pointer + 1;
            end
            
            // See if we are done.
            if(
              (~current_state.update_column_addr && next_state.spi_bytes_sent == 3)
              || (~current_state.update_row_addr && next_state.spi_bytes_sent == 3)
              || (current_state.update_column_addr && current_state.update_row_addr && next_state.spi_bytes_sent == 2)
            ) begin

              next_state.spi_bytes_done = '1; // We are done with this SPI command.
              next_state.spi_bit_valid  = '0; // We no longer need to send SPI data.
              next_state.spi_bytes_sent = '0; // Reset for the next command.

            end

          end

          // Mark our current SPI data as valid.
          else begin

            next_state.spi_bit_valid = '1;

          end

        end

      end

    endcase

    // SPI Machine:

    // See if we have new/current data to send over SPI.
    if(next_state.spi_bit_valid & current_state.sck) begin

      next_state.cs   = '0; // Always bring CS low if we have stuff to send.
      next_state.mosi = next_state.spi_byte[7 - next_state.spi_bit_pointer]; // Start with the MSB and go down from there.
      next_state.sck  = '0;
      next_state.dc   = next_state.spi_data_command;

    end

    // On a negative edge of SCK, do nothing.
    else if(next_state.spi_bit_valid & ~current_state.sck) begin
      next_state.sck = '1;
    end

    // Otherwise, SPI should be idle.
    else begin
      next_state.cs  = '1;
      next_state.sck = '1;
    end

    // Reset:
    if(~reset_n) begin
      next_state = '0;
    end

  end
endmodule
