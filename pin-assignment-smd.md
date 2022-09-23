## gm-proto-e1 Pin Assignment for SMD board variant

Note: Components are prefixed with "pr", to identify them belonging to the gm-proto-e1 application board.

#### 8x LED output "prled" on IO Bank NA

Name     | Location | Direction | Standard | comment
---------|----------|-----------|----------|---------
prled[0] | IO_NA_A8 | output    | 2.5V     |
prled[1] | IO_NA_A7 | output    | 2.5V     |
prled[2] | IO_NA_A6 | output    | 2.5V     |
prled[3] | IO_NA_A5 | output    | 2.5V     |
prled[4] | IO_NA_A4 | output    | 2.5V     |
prled[5] | IO_NA_A3 | output    | 2.5V     |
prled[6] | IO_NA_A2 | output    | 2.5V     |
prled[7] | IO_NA_A1 | output    | 2.5V     |

#### 2x 7-Segment Digits "prhex0" and "prhex1"

Name      | Location | Direction | Standard | comment
----------|----------|-----------|----------|-----------
prhex0[0] | IO_WC_B1 | output    | 2.5V     | hex0 - DP
prhex0[1] | IO_WC_B2 | output    | 2.5V     | hex0 - A
prhex0[2] | IO_WC_B3 | output    | 2.5V     | hex0 - B
prhex0[3] | IO_WC_B4 | output    | 2.5V     | hex0 - C
prhex0[4] | IO_WC_B5 | output    | 2.5V     | hex0 - D
prhex0[5] | IO_WC_B6 | output    | 2.5V     | hex0 - E
prhex0[6] | IO_WC_B7 | output    | 2.5V     | hex0 - F
prhex0[7] | IO_WC_B8 | output    | 2.5V     | hex0 - G

Name      | Location | Direction | Standard | comment
----------|----------|-----------|----------|--------
prhex1[0] | IO_WC_A8 | output    | 2.5V     | hex1 - DP
prhex1[1] | IO_WC_A7 | output    | 2.5V     | hex1 - A
prhex1[2] | IO_WC_A6 | output    | 2.5V     | hex1 - B
prhex1[3] | IO_WC_A5 | output    | 2.5V     | hex1 - C
prhex1[4] | IO_WC_A4 | output    | 2.5V     | hex1 - D
prhex1[5] | IO_WC_A3 | output    | 2.5V     | hex1 - E
prhex1[6] | IO_WC_A2 | output    | 2.5V     | hex1 - F
prhex1[7] | IO_WC_A1 | output    | 2.5V     | hex1 - G

#### 4x DIP Switch input "prswi" on IO Bank SA

Name     | Location | Direction | Standard | comment
---------|----------|-----------|----------|--------
prswi[0] | IO_SA_A1 | input     | 2.5V     |
prswi[1] | IO_SA_A2 | input     | 2.5V     |
prswi[2] | IO_SA_A3 | input     | 2.5V     |
prswi[3] | IO_SA_A4 | input     | 2.5V     |
prswi[4] | IO_SA_A5 | input     | 2.5V     |
prswi[5] | IO_SA_A6 | input     | 2.5V     |
prswi[6] | IO_SA_A7 | input     | 2.5V     |
prswi[7] | IO_SA_A8 | input     | 2.5V     |

#### 3x Push Buttons "prbtn" on IO Bank SA

Name     | Location | Direction | Standard | comment
---------|----------|-----------|----------|--------
prbtn[0] | IO_SA_A0 | input     | 2.5V     |
prbtn[1] | IO_SA_B0 | input     | 2.5V     |
prbtn[2] | IO_SA_B1 | input     | 2.5V     |


### 1x Buzzer "prbuz" on IO Bank WC

Name     | Location | Direction | Standard | comment
---------|----------|-----------|----------|--------
prbuz    | IO_WC_A0 | input     | 2.5V     |

For prototyping, 36 IO signals from GPIO banks SB, EA and EB have been placed into the 2.54mm area border pin rows.