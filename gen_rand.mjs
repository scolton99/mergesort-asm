import fs   from 'fs/promises';

const ARRAY_SIZE    = 106_490;
const ELEMENT_SIZE  = 'byte';

const SIZE_MAP = {
  byte: 8,
  word: 16,
  long: 32
};

const element_bits  = () => SIZE_MAP[ELEMENT_SIZE];
const bit_to_byte   = byte => byte >> 3;
const element_bytes = () => bit_to_byte(element_bits());
const array_bytes   = () => ARRAY_SIZE * element_bytes();

const HEADER =
`\t\t\t.cdecls C,LIST,"msp430.h"
\t\t\t.global INPUT_ARR,OUTPUT_ARR,ARR_SIZE,EL_SIZE

\t\t\t.data`;

const display = num => ("   " + num).slice(-4);

const main = async () => {
  const numbers = [];

  for (let i = 0; i < ARRAY_SIZE; ++i)
    numbers.push(Math.floor(Math.random() * Math.pow(2, SIZE_MAP[ELEMENT_SIZE])));

  const sections = [];

  for (let i = 0; i < ARRAY_SIZE; i += 100) {
    const section = numbers.slice(i, i + 100);
    const formatted_section = section.map(display);

    sections.push(formatted_section);
  }

  const data_output = sections.join(`\n\t\t\t.${ELEMENT_SIZE}`);

  const arr_size     = `ARR_SIZE\t.field ${ARRAY_SIZE}, 20`;
  const el_size      = `EL_SIZE\t\t.byte ${element_bits()}\t\t;; bits`;

  const input_array  = `INPUT_ARR\t.${ELEMENT_SIZE}${data_output}`;
  const output_array = `OUTPUT_ARR\t.space ${array_bytes()}`;

  const output = `${HEADER}\n${arr_size}\n${el_size}\n\n${input_array}\n\n${output_array}`;
  
  await fs.writeFile('data.asm', output);
};

main();